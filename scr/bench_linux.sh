#!/usr/bin/env bash
# stolen from https://www.scattered-thoughts.net/log/0053/

set -e

if [ "$(cat /sys/class/power_supply/ACAD/online)" != 1 ]
then
  echo "Don't benchmark on battery power"
  exit 1
fi

sudo benchmark_mode

# Run on reserved cpus
# High priority
# Record perf counters
sudo \
cgexec -g cpuset:benchmark \
nice -n -20 \
perf stat \
sudo -u jamie \
"$@"

benchmark_mode:

#!/usr/bin/env bash

set -e

# Setup benchmark cpus
if [ ! -d /sys/fs/cgroup/benchmark ]
then
    mkdir /sys/fs/cgroup/benchmark
fi
echo 'root' > /sys/fs/cgroup/benchmark/cpuset.cpus.partition
for f in /sys/fs/cgroup/*/cpuset.cpus; do echo '2-15' > $f; done
echo '0-1' > /sys/fs/cgroup/benchmark/cpuset.cpus

# Set scaling_governer to performance on benchmark cores
echo performance > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo performance > /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor

# Turn off turbo mode on all cpus
echo 1 > /sys/devices/system/cpu/intel_pstate/no_turbo

# Disable ASLR
echo 0 > /proc/sys/kernel/randomize_va_space

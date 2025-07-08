#!/usr/bin/env bash

# idea use ideas from aco24 in bash https://www.youtube.com/@bashcop/videos
# for general posix things, see ./templates/common.sh

#==== standard header
# set -x
set -eou
[[ "$(whoami)" = "root" ]] && return
trap 'cd ${CWD}' EXIT HUP INT QUIT SIGSEGV TERM
CWD=$(pwd)

# TODO
# * is_in_array
# * validate_args
# * print help

# loop array by index
SIZES=(
  200 800
)
for ((i=0;i<${#SIZES[*]};++i)); do
  echo "${SIZES[i]}"
done

# string/* is used verbatim without match, except we set nullglob
shopt -s nullglob
# disable it with `shopt -u nullglob`

# no cd around after failure
CWD=$(pwd)
trap 'cd ${CWD}' EXIT
# loop array by index
SIZES=(
  200 800
)
for ((i=0;i<${#SIZES[*]};++i)); do
  echo "${SIZES[i]}"
done

# jobs -l                                               to list all jobs
# disown [Job|-r RunningJob|-a|-h JobWithoutSIGHUB]     with -a for all jobs
#   Note: disown does not remove control from shell, so the job still gets terminated once shell is terminated. Use setsid for this.
# ps                                                    report snapshot of current process
# SHENNANIGAN 'setsid --fork is the only way to properly ensure that a command is run as a detached process.'
# setsid --fork                                         run program in new session

executables="test.xml"
for executable in ${executables}; do
 if [ "${executable: -4}" != ".xml" ]   \
 && [ "${executable: -4}" != ".txt" ]   \
 && [ "${executable: -4}" != ".csv" ]; then
  echo "file is no csv, txt or xml"
 fi
done

## based on https://www.baeldung.com/linux/csv-parsing
csv_file="file.csv"
echo 'SNo,Quantity,Price,Value
1,2,20,40
2,5,10,50' > csv_file

# 1. print lines
while read line
do
   echo "Line content: $line"
#done < file.csv
# 2. without first line
done < <(tail -n +2 file.csv)

# 3. parse line with read -r
while IFS="," read -r col1 col2 col3 col3 col4
do
  echo "col1: ${col1}"
  echo "col2: ${col2}"
  echo "col3: ${col3}"
  echo "col4: ${col4}"
  echo ""
done < <(tail -n +2 file.csv)

# $1 local array
# $2 local value
value_is_in_array() {
  array=(
    200 800
  )
  for i in "${array[@]}"; do
    if test "$i" == "$1"; then
      echo "value found for string" && exit 0
    fi
    if test "$i" -eq "$1"; then
      echo "value found for non-string" && exit 0
    fi
  done
}

validate_args() {
  echo ""
  # for var in "$@"; do
  #     echo "$var"
  # done
  # for ((i=0;i<${#SIZES[*]};++i)); do
  #   echo "${SIZES[i]}"
  # done
  # print elements of array according to IFS
  # echo "${ids[*]}"
}

if test -z "$1"; then
  echo 'output file name not set, exiting..'
  exit 0
fi

DATE_NOW=$(date +%Y%m%d)
echo "$DATE_NOW"
DIR=$(mktemp -d)
CUR=$PWD
cd "$DIR"

#DEVICE="'5CF3705DEFB9'"
# DEVICE="'airscan:w2:Brother ADS-1700W [5CF3705DEFB9]'"
# DEVICE="'v4l:/dev/video0 airscan:w2:Brother ADS-1700W'"
# -d "$DEVICE"
# --source 'ADF Duplex'
# -- resolution 100|150|200|300|400|600
DEVICE="airscan:w2:Brother"
MODE="Gray"
#a4 => -x 210 -y 297
scanimage -b --format tiff --device-name=$DEVICE --resolution 600 --mode $MODE --source 'ADF Duplex' -x 210 -y 297
#a5 => l=(210-148)/2
# scanimage -b --format tiff --device-name=$DEVICE --resolution 600 --mode $MODE --source 'ADF' -l 31 -x 148 -y 210
# --version-sort requires gnu coreutils
FILES=$(find ./ -type f | sort --version-sort | cut -sd / -f 2-)
magick convert $FILES -quality 10 -compress jpeg "$CUR/$1"

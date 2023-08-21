#!/usr/bin/env sh
# Script to deploy and fixup binary with user root having authorized_key and
# ssh running on target

set -e
set -x
ROOT=$(git rev-parse --show-toplevel)
CWD=$(pwd)
if test "${ROOT}" != "${CWD}"; then
  echo "CWD != ROOT"
  exit
fi

if test "$#" -lt 1; then
  echo "Usage: $0 TARGET_IP" >&2
  exit 1
fi

SCR_USER="root"
SCR_IP="$1"

# never forget : in path or scp has cp behavior
scp ./pathtobinary "user@${SCR_IP}:~"

ssh "${SCR_USER}@${SCR_IP}" 'systemctl stop supervision'
#ssh "${SCR_USER}@${SCR_IP}" 'wdctl -s 900 /dev/thewatchdog'
ssh "${SCR_USER}@${SCR_IP}" 'cp /home/user/binary /deploydir/bin/binary'
ssh "${SCR_USER}@${SCR_IP}" 'chown root.user /deploydir/bin/binary'
#ssh "${SCR_USER}@${SCR_IP}" 'chmod 123 /deploydir/bin/binary'
# ssh "${SCR_USER}@${SCR_IP}" 'setcap "xyz" /deploydir/bin/binary'
ssh "${SCR_USER}@${SCR_IP}" 'systemctl start supervision'
#ssh "${SCR_USER}@${SCR_IP}" 'wdctl -s 20 /dev/thewatchdog'

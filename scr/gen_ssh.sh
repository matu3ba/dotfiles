#!/bin/sh

command -v 'ssh' 1>/dev/null || (
  echo "please install ssh"
  exit 1
)

CWD=$(pwd)
if test "${CWD}" != "${HOME}"; then
  echo "must run from ${HOME}"
  exit 1
fi

if test $# -lt 3 || test $# -gt 5; then
  echo "Usage:
$0 \$1 \$2 [\$3]
  \$1: target user
  \$2: target ip
  \$3: keyname
  \$4: comment
  \$5: duplicate_ips_allowed
"
  exit 1
fi
USER=$1
IP=$2
KEYNAME=$3
COMMENT=$4
DUPLICATES_OK=$5

if test -z "${DUPLICATES_OK}"; then
  grep "${IP}" "${HOME}/.ssh/config"
  if test $? -eq 0; then
    echo "duplicate ip, exiting.."
    exit 1
  fi
fi
grep "${KEYNAME}" "${HOME}/.ssh/config"
if test $? -eq 0; then
  echo "duplicate keyname, exiting.."
  exit 1
fi

if test -f "${HOME}/.ssh/${KEYNAME}"; then
  echo "Found a key with this name, not creating another one."
else
  ssh-keygen -a 200 -t ed25519 -C "${COMMENT}" -f "${HOME}/.ssh/${KEYNAME}"
fi

echo 'Next steps: 1. .ssh/config addition, 2. cmd, 3. cmd'
echo 'On failure; edit on target ~/.ssh/authorized_keys + restart ssh on target'
# ECHOCMD1=$(echo "
#
# Host ${IP}
#   HostName ${IP}
#   User ${USER}
#   PreferredAuthentications publickey
#   IdentityFile ~/.ssh/${KEYNAME}
#   IdentitiesOnly yes
# ")
# ECHOCMD2=${HOME}/.ssh/config
# echo "echo '${ECHOCMD1}' >> ${ECHOCMD2}"

echo """
Host ${IP}
  HostName ${IP}
  User ${USER}
  PreferredAuthentications publickey
  IdentityFile ~/.ssh/${KEYNAME}
  IdentitiesOnly yes
""" >>"${HOME}/.ssh/config"

# SSHADDCMD=$(echo ssh-add "${HOME}/.ssh/$3")
# echo "${SSHADDCMD}"
echo ssh-add "${HOME}/.ssh/$3"
ssh-add "${HOME}/.ssh/$3"
# SSHCOPYIDCMD=$(echo "ssh-copy-id $USER@$IP")
# echo "${SSHCOPYIDCMD}"
echo "ssh-copy-id $USER@$IP"

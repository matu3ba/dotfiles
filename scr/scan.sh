#!/usr/bin/env sh
set -e

# Scanner Access Now Easy (SANE) is the defacto standard scanner api
# Some GUI frontends: xsane, simple-scan

if test -z "$1"; then
  echo 'output file name not set, exiting..'
  exit 0
fi
# time_now=$(date +%Y%m%d_%H%M%S)
DIR=$(mktemp -d)
CUR=$(pwd)
trap exit "cd $CUR"
cd "${DIR}"

#DEVICE = scanimage -L
#OUTHELP_DEVICE = scanimage --help -d DEVICE
#OUTHELP_SOURCE = scanimage --help -d DEVICE
# A4, color is default
# --mode Gray
# --resolution 300
scanimage -b --format tiff -d 'OUTHELP_DEVICE' --source 'OUTHELP_SOURCE' --resolution 150 -x 210 -y 297
FILES=$(find ./  -type f | cut -sd / -f 2-)
convert "${FILES}" -quality 10 -compress jpeg "$CUR/$1"

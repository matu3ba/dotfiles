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
scanimage -b --format tiff -d 'OUTHELP' --source 'OUTHELP_SOURCE' --resolution 150 -x 210 -y 297

for scans in * ; do
  tiff2pdf -j "${scans}" -o "${scans%%.*}.pdf"
done

#convert *.tif "$CUR/$1"
#convert *.tiff "$CUR/$1"
pdfunite ./*.pdf "$CUR/$1"

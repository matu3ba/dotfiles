#!/usr/bin/env sh
set -e

# Scanner Access Now Easy (SANE) is the defacto standard scanner api
# Some GUI frontends: xsane, simple-scan
#==DIN sizes:
#   Size Width x Height (mm) Width x Height (in)
#   4A0  1682  x 2378   mm   66.2  x 93.6   in
#   2A0  1189  x 1682   mm   46.8  x 66.2   in
#   A0   841   x 1189   mm   33.1  x 46.8   in
#   A1   594   x 841    mm   23.4  x 33.1   in
#   A2   420   x 594    mm   16.5  x 23.4   in
#   A3   297   x 420    mm   11.7  x 16.5   in
#   A4   210   x 297    mm   8.3   x 11.7   in
#   A5   148   x 210    mm   5.8   x 8.3    in
#   A6   105   x 148    mm   4.1   x 5.8    in
#   A7   74    x 105    mm   2.9   x 4.1    in
#   A8   52    x 74     mm   2.0   x 2.9    in
#   A9   37    x 52     mm   1.5   x 2.0    in
#   A10  26    x 37     mm   1.0   x 1.5    in

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
#a5 => l=(210-148)/2 => scanimage -b --format tiff -d 'OUTHELP_DEVICE' --source 'OUTHELP_SOURCE' --resolution 200 -l 31 -x 148 -y 210
scanimage -b --format tiff -d 'OUTHELP_DEVICE' --source 'OUTHELP_SOURCE' --resolution 150 -x 210 -y 297
FILES=$(find ./  -type f | cut -sd / -f 2-)
convert $FILES -quality 10 -compress jpeg "$CUR/$1"

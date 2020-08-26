#!/bin/sh
set -eu

: "${BINDIR:=/usr/local/sbin}"
: "${INPUTFILE:="$1"}"

cut -f2 "${INPUTFILE}" | while read -r product
do echo 'ACTION=="add", ATTRS{idVendor}=="1038", ATTRS{idProduct}=="'"${product}"'", RUN{program}+="'"${BINDIR}"'/apexctl keys on"'
done

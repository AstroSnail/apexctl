#!/bin/sh
set -eu

: "${INPUTFILE:="$1"}"
: "${HWDB_BODY:="$2"}"

cut -f2 "${INPUTFILE}" | while read -r product
do echo 'evdev:input:b0003v1038p'"${product}"'*'
done

cat "${HWDB_BODY}"

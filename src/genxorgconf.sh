#!/bin/sh
set -eu

: "${INPUTFILE:="$1"}"

cut -f1,2 "${INPUTFILE}" | while read -r line
do
  echo 'Section "InputClass"'
  echo '  Identifier "'"${line%	*}"'"'
  echo '  MatchUSBID "1038:'"${line#*	}"'"'
  # Only the Apex 300 model is included in Xorg
  # Other models may be developed later
  echo '  Option "XkbModel" "apex300"'
  echo 'EndSection'
done

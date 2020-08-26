#!/bin/sh
set -eu

: "${INPUTFILE:="$1"}"

n=$(wc -l "${INPUTFILE}")
n=${n% *}

echo '#include <stddef.h>'
echo '#include <stdint.h>'

echo 'size_t const steelseries_n = '"${n}"';'

echo 'uint16_t const steelseries_vendor = 0x1038;'

echo 'char const *const steelseries_names [] = {'
cut -f1 "${INPUTFILE}" | while read -r name
do echo '	"'"${name}"'",'
done
echo '};'

echo 'uint16_t const steelseries_products [] = {'
cut -f2 "${INPUTFILE}" | while read -r product
do echo "	0x${product},"
done
echo '};'

#!/bin/bash

. $TESTDIR/common.sh

to_codes()
{
	od -t u1 | sed 's/  */ /g' | cut -s -d' ' -f 2- | tr '\n' ' ' | sed 's/ $//'
}

FILEBASE=$TMPDIR/file-$$

printf "Alabama" > ${FILEBASE}-01
printf "Colorado, Alabama" > ${FILEBASE}-02
printf "abcdefghijklmnopqrstuvwxyz" > ${FILEBASE}-03
printf "ABCDEFGHIJKLMNOPQRSTUVWXYZ" > ${FILEBASE}-04
printf "0123456789" > ${FILEBASE}-05
printf "!#\"$%&\'()*+,-./:;<=> ?@[\\]^_\`{|}~" > ${FILEBASE}-06
printf "" > ${FILEBASE}-07
cp $TESTDIR/common.sh ${FILEBASE}-08
cp $(which echo) ${FILEBASE}-09
cat /bin/* > ${FILEBASE}-10
dd if=/dev/urandom of=${FILEBASE}-11 count=200 bs=200 2>/dev/null

FILE="$TMPDIR/$$"

for INPUT in ${FILEBASE}-*; do
	echo input=$INPUT
	< $INPUT $ascii -n | tr ' ' '\n' > $FILE.actual
	< $INPUT to_codes | tr ' ' '\n' > $FILE.expected
	diff -u $FILE.expected $FILE.actual || exit 1
done
exit 0

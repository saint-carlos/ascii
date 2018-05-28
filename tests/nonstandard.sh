#!/bin/bash

. $TESTDIR/common.sh

FILE="$TMPDIR/$$"
echo "100 120 40" > $FILE-01
seq 32 127 > $FILE-02
seq 0 255 > $FILE-03
seq -1000 1000 > $FILE-04
jot -r 600 -275 550 > $FILE-05

for INPUT in $FILE-*; do
	expected=$INPUT.expected
	actual=$INPUT.actual

	< $INPUT $ascii -an > $actual #2>/dev/null
	< $INPUT dummy_ascii true | to_chars > $expected
	vcmp $expected $actual || exit 1

	< $INPUT $ascii -apn > $actual 2>/dev/null
	< $INPUT dummy_ascii false | to_chars > $expected
	vcmp $expected $actual || exit 1
done
exit 0

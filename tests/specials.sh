#!/bin/bash

. $TESTDIR/common.sh

str[0]="100 120 40"
str[1]=`seq 32 126`
str[2]=`seq 0 255`
str[3]=""
str[4]=`seq -1000 1000`
str[5]=`jot -r 600 -275 550`

special_to_char_sed()
{
	tail -n +2 tests/specials.out  | tr '\t' ':' | awk -F: "$1"
}

short_to_char_sed()
{
	special_to_char_sed '{ printf("s,\\[%s\\],\\x%x,g;", $3, $1); }'
}

long_to_char_sed()
{
	special_to_char_sed '{ printf("s,\\[\"%s\\\"],\\x%x,g;", $4, $1); }'
}

special_to_char()
{
	local SCRIPT="$($1)"
	sed "$SCRIPT"
}

FILE="$TMPDIR/$$"

$ascii -l > $FILE.actual
diff -u tests/specials.out $FILE.actual || exit 1
$ascii -t > $FILE.actual
diff -u tests/all.out $FILE.actual || exit 1

for (( i=0 ; i < ${#str[@]} ; i++))
do
	echo "i=" $i

	echo case=an
	echo "${str[i]}" | $ascii -an > $FILE.actual
	echo "${str[i]}" | dummy_ascii true | to_chars > $FILE.expected
	vcmp $FILE.expected $FILE.actual || exit 1

	echo case=ans
	echo "${str[i]}" | $ascii -ans | special_to_char short_to_char_sed > $FILE.actual
	echo "${str[i]}" | dummy_ascii true | to_chars > $FILE.expected
	vcmp $FILE.expected $FILE.actual || exit 1

	echo case=anS
	echo "${str[i]}" | $ascii -anS | special_to_char long_to_char_sed > $FILE.actual
	echo "${str[i]}" | dummy_ascii true | to_chars > $FILE.expected
	vcmp $FILE.expected $FILE.actual || exit 1
done
exit 0

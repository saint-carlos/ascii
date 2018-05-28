#!/bin/bash

. $TESTDIR/common.sh

# randomize(lowerbound, upperbound-exclusive)
function randomize()
{
	v=$RANDOM
	v=$(( v % ($2 - $1) ))
	v=$(( v + $1 ))
	echo $v
}

# random_nums(lowerbound, upperbound-exclusive, amount)
function random_nums()
{
	for (( i=0 ; i < $3 ; i++ ))
	do
		res="$res `randomize $1 $2`"
	done
	echo "$res"
}

str[0]="100 120 40"
str[1]=`seq 32 127`
str[2]=`seq 0 255`
str[3]=
str[4]=`seq -500 500`
str[5]=`jot -r 600 -275 550`

FILE="$TMPDIR/$$"
for (( i=0 ; i < ${#str[@]} ; i++))
do
	echo "i=" $i
	echo "${str[i]}" | $ascii -an > $FILE.actual
	echo "${str[i]}" | dummy_ascii true | to_chars > $FILE.expected
	vcmp $FILE.expected $FILE.actual || exit 1
done
exit 0

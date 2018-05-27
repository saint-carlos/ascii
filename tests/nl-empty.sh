#!/bin/bash

. $TESTDIR/common.sh

set -e
# empty
test -z "`echo -n | $ascii`"
test -z "`echo -n | $ascii -a`"

# empty+newline

temp=`mktemp`

echo -n | $ascii -n > $temp
test `stat --printf %s $temp` -eq 0

echo -n | $ascii -an > $temp
test `stat --printf %s $temp` -eq 0

# newline

CHARS="$TMPDIR/$$-chars"
echo -n "Roses are #FF0000, violets are #0000FF - Chris Noe" > $CHARS-01
cp $TESTDIR/common.sh $CHARS-02

for INPUT in $CHARS-*; do
	linefeeds=`$ascii < $INPUT | wc -l`
	test $linefeeds -eq 1
	linefeeds=`$ascii -n < $INPUT | wc -l`
	test $linefeeds -eq 0
done

CODES="$TMPDIR/$$-codes"
echo -n "100 120 40" > $CODES-01
seq 500 > $CODES-02
echo -n 130 > $CODES-03
cat $0 | tr -cd " [:digit:]" > $CODES-04

for INPUT in $CODES-*; do
	regular_lf_count=`$ascii -a < $INPUT 2>/dev/null | wc -l`
	short_lf_count=`$ascii -an < $INPUT 2>/dev/null | wc -l`
	test `expr $short_lf_count + 1` -eq $regular_lf_count
done

# empty input newline
echo -n > $temp
test `$ascii < $temp | wc -l` -eq 0
test `$ascii -n < $temp | wc -l` -eq 0

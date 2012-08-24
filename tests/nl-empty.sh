#!/bin/sh
# check that -n option works and that empty strings work correctly.

# Copyright (C) 2000, 2002-2010 Free Software Foundation, Inc.

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

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

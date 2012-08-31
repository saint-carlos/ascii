#!/bin/bash
# make sure nonstandard characters are properly printed.

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
PLACEHOLDER=255

to_chars()
{
	xargs printf "%o\n" | sed 's/^/\\/' | tr -d '\n' | xargs -0 printf
}

make_placeholder()
{
	while read LINE; do
		for NUM in $LINE; do
			if [ $NUM -lt 0 ] || [ $NUM -ge 256 ]; then
				continue
			elif [ $NUM -ge 128 ]; then
				echo $PLACEHOLDER
			else
				echo $NUM
			fi
		done
	done
}

#to_chars()
#{
#	command='
#		if [ -z "`echo X | tr -d "[:digit:]"`" ] && [ X -gt 0 ] && [ X -lt 256 ]; then
#			printf "\\`printf %03o X`"
#		fi'
#	tr ' ' '\n' | xargs -I X sh -c "$command"
#}
#
#to_chars_placeholder()
#{
#	command='
#		if [ -z "`echo X | tr -d "[:digit:]"`" ] && [ X -gt 0 ] && [ X -lt 256 ]; then
#			if [ X -lt 128 ]
#				then printf "\\`printf %03o X`"
#				else printf "\\377"
#			fi
#		fi'
#	tr ' ' '\n' | xargs -I X sh -c "$command"
#}

FILE="$TMPDIR/$$"
echo "100 120 40" > $FILE-01
seq 32 127 > $FILE-02
seq 0 255 > $FILE-03
seq -1000 1000 > $FILE-04
jot 600 -275 550 > $FILE-05

expected=`mktemp $TMPDIR/expected.XXX`
actual=`mktemp $TMPDIR/actual.XXX`
for INPUT in $FILE-*; do
	< $INPUT $ascii -an > $actual 2>/dev/null
	< $INPUT make_placeholder | to_chars > $expected
	cmp $expected $actual || exit 1

	< $INPUT $ascii -apn > $actual 2>/dev/null
	< $INPUT to_chars > $expected
	cmp $expected $actual || exit 1
done
exit 0

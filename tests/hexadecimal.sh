#!/bin/sh
# check that ascii properly reads/writes hexadecimal ascii

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

to_codes()
{
	od -v -An -t x1 | tr -d '\n' | cut -c2- | sed 's/0\([0-9a-f]\)/\1/g'
}

set -e

# hexadecimal stdin input
echo 1 a b c d e f | mute_ascii -ax
echo a0 | mute_ascii -ax
echo "1f 2e 3d 4c 5b 6a a7 b8 c9 ea fb 0c 1d" | mute_ascii -ax
echo af fe 20 2d c3 c9 8b | mute_ascii -ax

# hexadecimal argv input
mute_ascii -ax 1 a b c d e f
mute_ascii -ax a0
mute_ascii -ax 1f 2e 3d 4c 5b 6a a7 b8 c9 ea fb 0c 1d
mute_ascii -ax af fe 20 2d c3 c9 8b
test "`$ascii -ax 78`" = "x"
test "`$ascii -ax 78 79 7a`" = "xyz"
test "`$ascii -ax 78 20 79 20 7a`" = "x y z"

set +e

# hexadecimal codes output
FILE="$TMPDIR/$$"
echo "Alabama" > $FILE-01
echo "Colorado, Alabama" > $FILE-02
echo "abcdefghijklmnopqrstuvwxyz" > $FILE-03
echo "ABCDEFGHIJKLMNOPQRSTUVWXYZ" > $FILE-04
echo "0123456789" > $FILE-05
echo "!\"#$%&'()*+,-./:;<=>?@[\\]^_\`{|}~" > $FILE-06
echo "" > $FILE-08
cat $TESTDIR/common.sh > $FILE-09
cp `which echo` $FILE-10
cat /bin/* > $FILE-11
dd if=/dev/urandom of=$FILE-11 count=200 bs=200 2>/dev/null

expected=`mktemp expected.XXX`
actual=`mktemp actual.XXX`
for INPUT in $FILE-*; do
	to_codes < $INPUT > $expected
	$ascii -x < $INPUT > $actual
	cmp $expected $actual || exit 1
done
exit 0

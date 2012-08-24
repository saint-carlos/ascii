#!/bin/sh

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

loopback_ascii()
{
	$ascii | $ascii -apn
}

loopback_ascii_a()
{
	$ascii -apn | $ascii
}

set -e

temp=`mktemp`

< $TESTDIR/common.sh loopback_ascii > $temp
cmp $TESTDIR/common.sh $temp
< $TESTDIR/common.sh loopback_ascii | loopback_ascii > $temp
cmp $TESTDIR/common.sh $temp

rand=`mktemp`
jot -s ' ' -r 800 0 255 > $rand

< $rand loopback_ascii_a > $temp
cmp $rand $temp
< $rand loopback_ascii_a | loopback_ascii_a > $temp
cmp $rand $temp

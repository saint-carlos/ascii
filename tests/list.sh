#!/bin/sh
# check that -l option works correctly.

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

mute_ascii -l
mute_ascii -alp

$ascii -l | grep 03 | grep -q "end of text"
$ascii -l | grep 0b | grep -q VT
$ascii -l | grep 15 | grep -q NAK
$ascii -l | grep 1e | grep -q "record separator"
$ascii -l | grep 127 | grep DEL | grep -q "delete"

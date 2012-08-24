#!/bin/sh
# verify that ascii reads input correctly from arguments.

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

#sanity
mute_ascii x
mute_ascii xyz
mute_ascii x y z
mute_ascii xyz abc
mute_ascii -a 1
mute_ascii -a 100
mute_ascii -a 50 60 70
mute_ascii -a 100 20

test "`$ascii x`" = "120"
test "`$ascii x y z`" = "120 121 122"
test "`$ascii xyz`" = "120 121 122"
test "`$ascii "x y z"`" = "120 32 121 32 122"

test "`$ascii -a 120`" = "x"
test "`$ascii -a 120 121 122`" = "xyz"
test "`$ascii -a 120 32 121 32 122`" = "x y z"

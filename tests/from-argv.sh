#!/bin/bash

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

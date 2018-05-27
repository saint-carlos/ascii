#!/bin/bash

. $TESTDIR/common.sh
set -e

#sanity
echo x | mute_ascii
echo xyz | mute_ascii
echo x y z | mute_ascii
echo "xyz abc" | mute_ascii
echo 1 | mute_ascii -a
echo 100 | mute_ascii -a
echo "50 60 70" | mute_ascii -a
echo 100 20 | mute_ascii -a

test "`echo -n x | $ascii`" = "120"
test "`echo -n xyz | $ascii`" = "120 121 122"
test "`echo -n "x y z" | $ascii`" = "120 32 121 32 122"

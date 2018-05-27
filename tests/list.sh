#!/bin/bash

. $TESTDIR/common.sh
set -e

mute_ascii -l
mute_ascii -alp

$ascii -l | grep 03 | grep -q "end of text"
$ascii -l | grep 0b | grep -q VT
$ascii -l | grep 15 | grep -q NAK
$ascii -l | grep 1e | grep -q "record separator"
$ascii -l | grep 127 | grep DEL | grep -q "delete"

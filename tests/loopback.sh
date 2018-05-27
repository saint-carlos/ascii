#!/bin/bash

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

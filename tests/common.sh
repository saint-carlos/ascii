#!/bin/sh

mute_ascii()
{
	$ascii "$@" > /dev/null 2>&1
}

if $VERBOSE; then
  set -x
fi

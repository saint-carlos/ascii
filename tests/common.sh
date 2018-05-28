#!/bin/bash

PLACEHOLDER=255

vcmp()
{
	cmp --print-bytes --verbose "$@"
}

mute_ascii()
{
	$ascii "$@" &> /dev/null
}

to_chars()
{
	tr ' ' '\n' \
		| xargs -L 1 --no-run-if-empty printf '\\\\%o\n' \
		| xargs -L 1 printf
}

dummy_ascii()
{
	while read LINE; do
		for NUM in $LINE; do
			if [ $NUM -lt 0 ] || [ $NUM -ge 256 ]; then
				continue
			fi
			if $1 && [ $NUM -ge 128 ]; then
				NUM="$PLACEHOLDER"
			fi
			printf "$NUM "
		done
		echo
	done
}

if $VERBOSE; then
  set -xv
fi

#!/bin/bash

. $TESTDIR/common.sh
temp=`mktemp`

is_integer()
{
	test -z "`echo $1 | tr -d "[:digit:]"`"
}

verify_line()
{
	tokens="$@"
	$ascii -a -- $tokens > /dev/null 2> $temp && return 1
	expected=""
	for token in $tokens
	do
		if ! is_integer $token || test $token -lt 0 || test $token -ge 256; then
			expected="${expected}${token};"
		fi
	done
	test "$expected" = "`cat $temp`" || fail=1
}

verify_stderr()
{
	while read line; do
		verify_line $line || return 1
	done
	return 0

}

false_positive=false
false_negative=false
mute_ascii -a -- 1000	&& false_positive=true
mute_ascii -a -- 500	&& false_positive=true
mute_ascii -a -- 256	&& false_positive=true
mute_ascii -a -- 255	|| false_negative=true
mute_ascii -a -- 180	|| false_negative=true
mute_ascii -a -- 128	|| false_negative=true
mute_ascii -a -- 127	|| false_negative=true
mute_ascii -a -- 64	|| false_negative=true
mute_ascii -a -- 32	|| false_negative=true
mute_ascii -a -- 16	|| false_negative=true
mute_ascii -a -- 1	|| false_negative=true
mute_ascii -a -- 0	|| false_negative=true
mute_ascii -a -- -1	&& false_positive=true
mute_ascii -a -- -10	&& false_positive=true
mute_ascii -a -- -100	&& false_positive=true
mute_ascii -a -- -1000	&& false_positive=true
mute_ascii -a -- a	&& false_positive=true
mute_ascii -a -- abc	&& false_positive=true

inputs=`mktemp`
cat > $inputs << EOF
2 4 8 16 32 64 128 256
-8 2 4 8 16 32 64 128
2 512 4 8 16 32 64 128
2 4 8 -16 16 32 64 128
2 4 8 16 1024 32 2048 64 128
2 4 4096 8 16 32 -1 64 128
2 4 8 16 32 64 128 -32
2 4 8 -1 16 32 64 4096 128
2 4 8 1000 1000 16 32 1000 64 128
2 4 -1 8 16 -3 32 64 -1 128 -19
-2 -4 -8 -16 -32 -64 -128
2000 400 800 1600 320 640 1280
2 4000 -8 1600 -32 640 -128
2 4 8 abc 16 32 64 128
abc 2 4 8 16 32 64 128
2 4 8 16 32 64 128 abc
2 4 8 abc 16 32 64 128 defgh
EOF

verify_stderr < $inputs || exit 1

if $false_positive || $false_negative; then
	exit 1
else
	exit 0
fi

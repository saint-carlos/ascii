#!/bin/sh

ascii="$1"
TMPDIR="$2"
export ascii TMPDIR
shift 2

TESTS="$@"
TESTDIR=tests
export TESTDIR

: ${VERBOSE:=false}
export VERBOSE
if $VERBOSE; then
	$ascii --version
fi

for TEST in $TESTS; do
	$TEST && continue
	echo "test `basename $TEST` failed!"
	exit 1
done
echo "all tests passed!"
exit 0

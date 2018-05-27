#!/bin/bash

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
	run_test()
	{
		"$1"
	}
else
	run_test()
	{
		"$1" &> /dev/null
	}
fi

RC=0
PASSED=0
FAILED=0
for TEST in $TESTS; do
	rm -rf $TMPDIR/*
	printf "\ttest $(basename $TEST)..."
	run_test $TEST
	if [ $? -eq 0 ]; then
		printf " passed\n"
		((PASSED++))
	else
		printf " failed!\n"
		((FAILED++))
		RC=1
	fi
done
if [ $RC -eq 0 ]; then
	echo "all $PASSED tests passed!"
else
	echo "$FAILED out of $((FAILED + PASSED)) tests failed!"
fi
exit $RC

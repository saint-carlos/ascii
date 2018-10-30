CEXEC := ascii
PYEXEC := ascii.py

TMP_TEST := tests/tmp
TEST_FILES := error.sh from-argv.sh from-stdin.sh hexadecimal.sh list.sh loopback.sh nl-empty.sh nonstandard.sh specials.sh to-chars.sh to-codes.sh
TESTS := $(addprefix tests/,${TEST_FILES})

all: ${CEXEC} ${PYEXEC}

clean:
	rm -rf ${TMP_TEST}
	rm -f ${CEXEC}

test: ctest pytest

ctest: ${CEXEC} ${TESTS}
	mkdir -p ${TMP_TEST}
	tests/run.sh ${CURDIR}/${CEXEC} ${TMP_TEST} ${TESTS}

pytest: ${PYEXEC} ${TESTS}
	mkdir -p ${TMP_TEST}
	tests/run.sh ${CURDIR}/${PYEXEC} ${TMP_TEST} ${TESTS}

%: tests/%.sh
	mkdir -p ${TMP_TEST}
	tests/run.sh ${CURDIR}/${CEXEC} ${TMP_TEST} $<

EXEC := ascii.py
TMP_TEST := tests/tmp
TEST_FILES := error.sh from-argv.sh from-stdin.sh hexadecimal.sh list.sh loopback.sh nl-empty.sh nonstandard.sh specials.sh to-chars.sh to-codes.sh
TESTS := $(addprefix tests/,${TEST_FILES})

all: ${EXEC}

clean:
	rm -rf ${EXEC} ${TMP_TEST}

test: ${EXEC} ${TESTS}
	mkdir -p ${TMP_TEST}
	tests/run.sh ${CURDIR}/${EXEC} ${TMP_TEST} ${TESTS}

%: tests/%.sh
	mkdir -p ${TMP_TEST}
	tests/run.sh ${CURDIR}/${EXEC} ${TMP_TEST} $<

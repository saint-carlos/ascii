EXEC := ascii
TMP_TEST := tests/tmp
TEST_FILES := error.sh from-argv.sh from-stdin.sh hexadecimal.sh
TESTS := $(addprefix tests/,${TEST_FILES})

all: ${EXEC}

clean:
	rm -rf ${EXEC} ${TMP_TEST}

test: ${EXEC} ${TESTS}
	mkdir -p ${TMP_TEST}
	tests/run.sh ${CURDIR}/${EXEC} ${TMP_TEST} ${TESTS}

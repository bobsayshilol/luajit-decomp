#!/bin/bash

# TODO: better test suite

TESTS_LOCATION=tests
TMP_LOCATION=/tmp

for TEST_NAME in $(ls tests); do
	input=${TESTS_LOCATION}/${TEST_NAME}/input.lua
	output=${TESTS_LOCATION}/${TEST_NAME}/output.lua

	luajit -blg ${input} ${TESTS_LOCATION}/${TEST_NAME}/output.asm

	echo
	echo "Running test '${TEST_NAME}'..."

	luajit -b ${input} ${TMP_LOCATION}/test_in.luac
	lua decoder.lua ${TMP_LOCATION}/test_in.luac ${TMP_LOCATION}/test_out.lua > /dev/null
	if [ $? -ne 0 ]; then
		echo "Test '${TEST_NAME}' failed"
		continue
	fi

	diff ${TMP_LOCATION}/test_out.lua ${output}
	if [ $? -ne 0 ]; then
		echo "Test '${TEST_NAME}' failed"
		continue
	fi

	echo "Test '${TEST_NAME}' succeeded"
done

#!/bin/sh
# build testcase
bash sim_build.sh $@
# copy test input
if [ -f ./testcase/$@.in ]; then cp ./testcase/$@.in ./test/test.in; fi
# copy test output
if [ -f ./testcase/$@.ans ]; then cp ./testcase/$@.ans ./test/test.ans; fi
# add your own test script here
# Example:
# - iverilog/gtkwave/vivado
# - diff ./test/test.ans ./test/test.out

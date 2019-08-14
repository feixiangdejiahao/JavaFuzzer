#!/bin/bash
set -u

# Max time to run the test for
TIMEOUT=120

timeout $TIMEOUT $* Test > test.out
if [ $? -eq 0 ]; then
  zcat golden.out.gz > golden.out
  cmp golden.out test.out
  if [ $? -eq 0 ]; then
    echo "$PWD: Passed"
  else
    echo "$PWD: Failed"
  fi
else
  echo "$PWD: Timeout"
fi

rm *.out

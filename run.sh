#!/bin/bash

TIMEOUT=30

R=`pwd`

for T in `find -iname Test.java -printf "%h\n" | sort`; do
  cd $T
  echo -n "$T: "

  timeout $TIMEOUT $* -cp .:.. Test > test.out
  if [ $? -eq 0 ]; then
    cmp golden.out test.out
    if [ $? -eq 0 ]; then
      echo "Passed"
    else
      echo "Failed"
    fi
  else
    echo "Timeout"
  fi

  rm test.out
  cd $R
done


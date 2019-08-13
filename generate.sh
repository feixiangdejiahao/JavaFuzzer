#!/bin/bash

NUM_TESTS=10
TIMEOUT=5
R=`pwd`

rm -rf tests/
mkdir tests/
cp $R/rb/FuzzerUtils.java tests/
cp run.sh tests/
cd tests/
javac FuzzerUtils.java
cd ..

for T in `seq 1 $NUM_TESTS`; do
  mkdir tests/$T
  cd tests/$T
  while true; do
    ruby -I$R/rb $R/rb/Fuzzer.rb -f $R/rb/config.yml > Test.java
    cp ../FuzzerUtils.class .
    javac Test.java

    timeout $TIMEOUT java Test > golden.out
    if [ $? -eq 0 ]; then
        echo -n "."
	break;
    else
        echo -n "!"
    fi
  done
  cd $R
done

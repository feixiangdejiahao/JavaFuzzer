#!/bin/bash
set -u

# Number of tests to generate in the bundle
NUM_TESTS=10

# Maximum test running time to be considered stable.
# Note it covers for generated tests that never finish, and also for tests that would
# run longer in some unusual JVM mode (for example, with lots of verification).
# Time is in seconds.
TIMEOUT=5

# Output directory
OUTDIR=tests/

R=`pwd`

rm -rf $OUTDIR
mkdir $OUTDIR
cp $R/rb/FuzzerUtils.java $OUTDIR
cp run.sh $OUTDIR
cd $OUTDIR
javac FuzzerUtils.java
cd ..

for T in `seq 1 $NUM_TESTS`; do
  mkdir $OUTDIR/$T
  cd $OUTDIR/$T
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

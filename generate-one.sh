#!/bin/bash
set -u

# Maximum test running time to be considered stable.
# Note it covers for generated tests that never finish, and also for tests that would
# run longer in some unusual JVM mode (for example, with lots of verification).
# Time is in seconds.
COMP_TIMEOUT=10

# Target that interpreter is about 100x slower; everything else
# is something off the rails, e.g. code that is generally dead
INT_TIMEOUT=1000

R=$1

while true; do
  rm -f *.java Fuzzer* *.out
  ruby -I$R/rb $R/rb/Fuzzer.rb -f $R/rb/config.yml > Test.java
  ln -s ../FuzzerUtils.class
  javac --release 8 Test.java

  # Trial baloon: does it timeout in compiled mode?
  timeout $COMP_TIMEOUT java Test > /dev/null
  EXIT_CODE=$?
  if [ $EXIT_CODE -eq 124 ]; then
    # Timeout, try again
    echo -n ";"
    continue;
  fi

  # Runs in reasonable time in compiled mode, compute golden output
  timeout $INT_TIMEOUT java -Xint Test > golden.out
  EXIT_CODE=$?
  if [ $EXIT_CODE -eq 0 ]; then
    # Good, move on
    echo -n "."
    rm *.class
    break;
  elif [ $EXIT_CODE -eq 124 ]; then
    # Timeout, try again
    echo -n ","
    continue;
  else
    # Some other error, try again
    echo -n "!"
    continue;
  fi
done

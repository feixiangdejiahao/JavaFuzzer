#!/bin/bash
set -u

TEST_OPTS="-Xmx256m"

# Maximum test running time to be considered stable.
# Note it covers for generated tests that never finish, and also for tests that would
# run longer in some unusual JVM mode (for example, with lots of verification).
# Time is in seconds.
C2_TIMEOUT=10

# Target that C1 is about 10x slower: unusual exceptions, like Div/0 exceptions
# make the generated code slower than C2.
C1_TIMEOUT=100

# Target that interpreter is about 100x slower; everything else
# is something off the rails, e.g. code that is generally dead
INT_TIMEOUT=1000

R=$1

while true; do
  rm -f *.java Fuzzer* *.out
  ruby -I$R/rb $R/rb/Fuzzer.rb -f $R/rb/config.yml > Test.java
  cp ../FuzzerUtils.class .
  javac --release 8 Test.java

  # Trial balloon: does it timeout in C2?
  timeout $C2_TIMEOUT java $TEST_OPTS -XX:-TieredCompilation Test > /dev/null
  EXIT_CODE=$?
  if [ $EXIT_CODE -eq 124 ]; then
    # Timeout, try again
    echo -n ";"
    continue;
  fi

  # Trial balloon: does it timeout in C1?
  timeout $C1_TIMEOUT java $TEST_OPTS -XX:TieredStopAtLevel=1 Test > /dev/null
  EXIT_CODE=$?
  if [ $EXIT_CODE -eq 124 ]; then
    # Timeout, try again
    echo -n ";"
    continue;
  fi

  # Runs in reasonable time in compiled mode, compute golden output
  timeout $INT_TIMEOUT java $TEST_OPTS -Xint Test > golden.out
  EXIT_CODE=$?
  if [ $EXIT_CODE -eq 0 ]; then
    # Good, move on
    echo -n "."
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

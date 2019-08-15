#!/bin/bash
set -u

# Maximum test running time to be considered stable.
# Note it covers for generated tests that never finish, and also for tests that would
# run longer in some unusual JVM mode (for example, with lots of verification).
# Time is in seconds.
TIMEOUT=5

R=$1

while true; do
  ruby -I$R/rb $R/rb/Fuzzer.rb -f $R/rb/config.yml > Test.java
  ln -s ../FuzzerUtils.class
  javac Test.java

  timeout $TIMEOUT java Test > golden.out
  EXIT_CODE=$?
  if [ $EXIT_CODE -eq 0 ]; then
    # Test is okay, pack up and move on
    echo -n "."
    gzip -9 golden.out
    gzip -9 Test.java
    break;
  elif [ $EXIT_CODE -eq 124 ]; then
    # Timeout, try again
    echo -n ":"
    rm FuzzerUtils.class Test.java*
  else
    # Some other error, keep everything in place for inspection
    # and move on
    echo -n "!"
    break;
  fi
done

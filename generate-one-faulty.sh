#!/bin/bash
set -u

# Maximum test running time to be considered stable.
# Note it covers for generated tests that never finish, and also for tests that would
# run longer in some unusual JVM mode (for example, with lots of verification).
# Time is in seconds.
TIMEOUT=20

R=$1

while true; do
  ruby -I$R/rb $R/rb/Fuzzer.rb -f $R/rb/config.yml > Test.java
  ln ../FuzzerUtils.class
  javac Test.java

  timeout $TIMEOUT java Test > golden.out
  EXIT_CODE=$?
  if [ $EXIT_CODE -eq 0 ]; then
    echo -n "."
    rm FuzzerUtils.class
  elif [ $EXIT_CODE -eq 124 ]; then
    echo -n ":"
    rm FuzzerUtils.class
  else
    echo -n "!"
    break;
  fi
done

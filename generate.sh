#!/bin/bash
set -u

# Number of tests to generate in the bundle
NUM_TESTS=100000

PARALLEL=16

# Output directory
OUTDIR=tests/

R=`pwd`

rm -rf $OUTDIR
mkdir $OUTDIR
cp $R/rb/FuzzerUtils.java $OUTDIR
cp run*.sh $OUTDIR
cd $OUTDIR
javac --release 8 FuzzerUtils.java
cd ..

seq -w 1 $NUM_TESTS | xargs -n 1 -P $PARALLEL -I TESTID bash -c "mkdir $OUTDIR/TESTID; cd $OUTDIR/TESTID; $R/generate-one.sh $R"

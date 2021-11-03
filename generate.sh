#!/bin/bash
set -u

# Number of tests to generate in the bundle
NUM_TESTS=1000

PARALLEL=32

# Output directory
OUTDIR=tests/

OUTDIR_JDK_X=tests-jdkX/
OUTDIR_JDK_11=tests-jdk11/
OUTDIR_JDK_8=tests-jdk8/

R=`pwd`

rm -rf $OUTDIR
mkdir $OUTDIR
cp $R/rb/FuzzerUtils.java $OUTDIR
cd $OUTDIR
javac --release 8 FuzzerUtils.java
cd ..

seq -w 1 $NUM_TESTS | xargs -n 1 -P $PARALLEL -I TESTID bash -c "mkdir $OUTDIR/TESTID; cd $OUTDIR/TESTID; $R/generate-one.sh $R"

rm $OUTDIR/*.java
rm $OUTDIR/*.class

rm -rf $OUTDIR_JDK_X
rm -rf $OUTDIR_JDK_11
rm -rf $OUTDIR_JDK_8

cp -r $OUTDIR $OUTDIR_JDK_X
cp -r $OUTDIR $OUTDIR_JDK_11
cp -r $OUTDIR $OUTDIR_JDK_8

seq -w 1 $NUM_TESTS | xargs -n 1 -P $PARALLEL -I TESTID bash -c "cp $R/JtregTestX.java  $OUTDIR_JDK_X/TESTID/JtregTest.java"
seq -w 1 $NUM_TESTS | xargs -n 1 -P $PARALLEL -I TESTID bash -c "cp $R/JtregTest11.java $OUTDIR_JDK_11/TESTID/JtregTest.java"
seq -w 1 $NUM_TESTS | xargs -n 1 -P $PARALLEL -I TESTID bash -c "cp $R/JtregTest8.java  $OUTDIR_JDK_8/TESTID/JtregTest.java"

seq -w 1 $NUM_TESTS | xargs -n 1 -P $PARALLEL -I TESTID bash -c "cp $R/rb/FuzzerUtils.java $OUTDIR_JDK_X/TESTID/"
seq -w 1 $NUM_TESTS | xargs -n 1 -P $PARALLEL -I TESTID bash -c "cp $R/rb/FuzzerUtils.java $OUTDIR_JDK_11/TESTID/"
seq -w 1 $NUM_TESTS | xargs -n 1 -P $PARALLEL -I TESTID bash -c "cp $R/rb/FuzzerUtils.java $OUTDIR_JDK_8/TESTID/"

echo
. package.sh

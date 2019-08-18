#!/bin/bash
set -u

rm tests.tar.xz

find tests/ -type f | \
  awk -F '/' '{ k = $(NF); sub(/ /, "", k); print k " " $L; }' | \
  sort | \
  cut -d" " -f 2- > list.txt

tar -c -f tests.tar -T list.txt
rm list.txt

pxz -9 tests.tar

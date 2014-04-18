#!/bin/sh

pub install

dart test/bitset_test.dart
dart test/fixed_length_bitset_test.dart

run_using_dart2js() {
  mkdir /tmp/dart2js-output
  dart2js -o /tmp/dart2js-output/output.js $1
  node /tmp/dart2js-output/output.js
  rm -r /tmp/dart2js-output
}

# TODO: test/bitset_test.dart can't run in dart2js
# run_using_dart2js test/bitset_test.dart
run_using_dart2js test/fixed_length_bitset_test.dart

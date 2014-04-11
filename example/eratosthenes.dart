import 'dart:io';
import 'dart:math';

import 'package:bitset/bitset.dart';

void main() {
  int input = 105944;//int.parse(stdin.readLineSync());
  BitSet sieve = new BitSet(input);
  int size = sieve.size();
  for (int i = 2; i < size; i++) {
    sieve.setBit(i);
  }
  int finalBit = sqrt(size).floor();
  for ( int i = 2; i < finalBit; i++ ) {
    if (sieve[i]) {
      for (int j = 2 * i; j < size; j += i) { 
        sieve.clearBit(j);
      }
    }
  }
  if (sieve[input])
    print("$input is a prime number");
  else
    print("$input is not a prime number");
}

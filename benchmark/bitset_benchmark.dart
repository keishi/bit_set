import 'dart:math';

import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:bitset/bitset.dart';

class VariableLengthBitSetCountBenchmark extends BenchmarkBase {
  final int bitsPerElement;
  static List<BitSet> bitSets;
  static Random random;

  static BitSet createRandomBitSet(int bitCount, int bitsPerElement) {
    BitSet bitset = new VariableLengthBitSet(bitCount, bitsPerElement);
    for (int i = 0; i < bitCount; ++i) {
      bitset[i] = random.nextBool();
    }
    return bitset;
  }

  const VariableLengthBitSetCountBenchmark(String name, this.bitsPerElement) : super(name);

  static void main(int bitsPerElement) {
    new VariableLengthBitSetCountBenchmark("VariableLengthBitSetCount[$bitsPerElement]", bitsPerElement).report();
  }

  // The benchmark code.
  void run() {
    const int EXPECTED_TOTAL_COUNT = 131164;
    int totalCount = bitSets.fold(0, (s, b) => s + b.count());
    if (totalCount != EXPECTED_TOTAL_COUNT) {
      print ("ERROR: totalCount($totalCount) != EXPECTED_TOTAL_COUNT($EXPECTED_TOTAL_COUNT)");
    }
  }

  // Not measured setup code executed prior to the benchmark runs.
  void setup() {
    random = new Random(0);
    bitSets = new List<BitSet>.generate(256, (i) => createRandomBitSet(1024, bitsPerElement), growable:false);
  }

  // Not measures teardown code executed after the benchark runs.
  void teardown() { }
}

class VariableLengthBitSetXorBenchmark extends BenchmarkBase {
  final int bitsPerElement;
  static List<BitSet> bitSets;
  static Random random;

  static BitSet createRandomBitSet(int bitCount, int bitsPerElement) {
    BitSet bitset = new VariableLengthBitSet(bitCount, bitsPerElement);
    for (int i = 0; i < bitCount; ++i) {
      bitset[i] = random.nextBool();
    }
    return bitset;
  }

  const VariableLengthBitSetXorBenchmark(String name, this.bitsPerElement) : super(name);

  static void main(int bitsPerElement) {
    new VariableLengthBitSetXorBenchmark("VariableLengthBitSetXor[$bitsPerElement]", bitsPerElement).report();
  }

  // The benchmark code.
  void run() {
    const String EXPECTED_RESULT = "1100011100001100100111011010100000001110111010100100011010001101";
    String result = bitSets.reduce((a, b) => a ^ b).toString();
    if (result != EXPECTED_RESULT) {
      print ("ERROR: result($result) != EXPECTED_RESULT($EXPECTED_RESULT)");
    }
  }

  // Not measured setup code executed prior to the benchmark runs.
  void setup() {
    random = new Random(0);
    bitSets = new List<BitSet>.generate(512, (i) => createRandomBitSet(64, bitsPerElement), growable:false);
  }

  // Not measures teardown code executed after the benchark runs.
  void teardown() { }
}

class VariableLengthBitSetEratosthenesSieveBenchmark extends BenchmarkBase {
  final int bitsPerElement;
  static Random random;

  const VariableLengthBitSetEratosthenesSieveBenchmark(String name, this.bitsPerElement) : super(name);

  static void main(int bitsPerElement) {
    new VariableLengthBitSetEratosthenesSieveBenchmark("VariableLengthBitSetEratosthenesSieve[$bitsPerElement]", bitsPerElement).report();
  }

  // The benchmark code.
  void run() {
    int input = 8831;
    BitSet sieve = new VariableLengthBitSet(input, bitsPerElement);
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
    if (!sieve[input]) {
      print ("ERROR: 8831 is a prime number");
    }
  }

  // Not measured setup code executed prior to the benchmark runs.
  void setup() {
    random = new Random(0);
  }

  // Not measures teardown code executed after the benchark runs.
  void teardown() { }
}

main() {
  VariableLengthBitSetEratosthenesSieveBenchmark.main(8);
  VariableLengthBitSetEratosthenesSieveBenchmark.main(16);
  VariableLengthBitSetEratosthenesSieveBenchmark.main(32);
  VariableLengthBitSetEratosthenesSieveBenchmark.main(64);

  VariableLengthBitSetCountBenchmark.main(8);
  VariableLengthBitSetCountBenchmark.main(16);
  VariableLengthBitSetCountBenchmark.main(32);
  VariableLengthBitSetCountBenchmark.main(64);

  VariableLengthBitSetXorBenchmark.main(8);
  VariableLengthBitSetXorBenchmark.main(16);
  VariableLengthBitSetXorBenchmark.main(32);
  VariableLengthBitSetXorBenchmark.main(64);
}

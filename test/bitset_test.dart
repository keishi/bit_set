import 'package:unittest/unittest.dart';
import 'package:bitset/bitset.dart';

void main() {

  Set<int> supportedBitsPerElement = new Set<int>.from([8, 16]);
  if ((1 << 31) > 0) {
    supportedBitsPerElement.add(32);
  }
  if ((1 << 63) > 0) {
    supportedBitsPerElement.add(64);
  }

  for (int bitsPerElement in supportedBitsPerElement) {
    test("fromString/toString [$bitsPerElement]", () {
      expect(new BitSet.fromString("0", bitsPerElement).toString(), equals(""));
      expect(new BitSet.fromString("1", bitsPerElement).toString(), equals("1"));
      expect(new BitSet.fromString("101", bitsPerElement).toString(), equals("101"));
      expect(new BitSet.fromString("0111", bitsPerElement).toString(), equals("111"));
      expect(new BitSet.fromString("000000000000000000000000000000001").toString(), equals("1"));
      expect(new BitSet.fromString("00000000000000000000000000000000000000000000000000000000000000001", bitsPerElement).toString(), equals("1"));
      expect(new BitSet.fromString("11000000000000000000000000000000000000000000000000000000000000001", bitsPerElement).toString(), equals("11000000000000000000000000000000000000000000000000000000000000001"));
    });

    test("equality [$bitsPerElement]", () {
      expect(new BitSet.fromString("0", bitsPerElement), equals(new BitSet(null)));
      expect(new BitSet.fromString("0", bitsPerElement), equals(new BitSet.fromString("0")));
      expect(new BitSet.fromString("1", bitsPerElement), equals(new BitSet.fromString("1")));
      expect(new BitSet.fromString("01", bitsPerElement), equals(new BitSet.fromString("1")));
      expect(new BitSet.fromString("1", bitsPerElement), equals(new BitSet.fromString("01")));
      expect(new BitSet.fromString("00000000000000000000000000000000000000000000000000000000000000001", bitsPerElement), equals(new BitSet.fromString("1")));
      expect(new BitSet.fromString("1", bitsPerElement), equals(new BitSet.fromString("00000000000000000000000000000000000000000000000000000000000000001")));
      expect(new BitSet.fromString("110110101100001010101100000011101111110010", bitsPerElement), equals(new BitSet.fromString("110110101100001010101100000011101111110010")));
    });

    test("toString [$bitsPerElement]", () {
      BitSet bs = new VariableLengthBitSet(bitsPerElement);
      expect(bs.toString(), equals(""));
      bs.setBit(0);
      expect(bs.toString(), equals("1"));
      bs.setBit(2);
      expect(bs.toString(), equals("101"));
      bs.setBit(64);
      expect(bs.toString(), equals("10000000000000000000000000000000000000000000000000000000000000101"));

      bs.clearBit(64);
      expect(bs.toString(), equals("101"));
      expect(bs.count(), equals(2));
      bs.clearBit(1);
      expect(bs.toString(), equals("101"));
      expect(bs.count(), equals(2));
      bs.clearBit(0);
      expect(bs.toString(), equals("100"));

      bs.flipBit(0);
      expect(bs.toString(), equals("101"));
      bs.flipBit(2);
      expect(bs.toString(), equals("1"));
      bs.flipBit(64);
      expect(bs.toString(), equals("10000000000000000000000000000000000000000000000000000000000000001"));
    });

    test("toInt [$bitsPerElement]", () {
      BitSet bs = new VariableLengthBitSet(null, bitsPerElement);
      expect(bs.toInt(), equals(0));
      bs.setBit(0);
      expect(bs.toInt(), equals(1));
      bs.setBit(2);
      expect(bs.toInt(), equals(5));
      bs.setBit(64);
      expect(bs.toInt(), equals(18446744073709551621));

      bs.clearBit(64);
      expect(bs.toInt(), equals(5));
      expect(bs.count(), equals(2));
      bs.clearBit(1);
      expect(bs.toInt(), equals(5));
      expect(bs.count(), equals(2));
      bs.clearBit(0);
      expect(bs.toInt(), equals(4));

      bs.flipBit(0);
      expect(bs.toInt(), equals(5));
      bs.flipBit(2);
      expect(bs.toInt(), equals(1));
      bs.flipBit(64);
      expect(bs.toInt(), equals(18446744073709551617));
    });
    
    test("count [$bitsPerElement]", () {
      BitSet bs = new VariableLengthBitSet(null, bitsPerElement);
      expect(bs.count(), equals(0));
      bs.setBit(0);
      expect(bs.count(), equals(1));
      bs.setBit(2);
      expect(bs.count(), equals(2));
      bs.setBit(64);
      expect(bs.count(), equals(3));
      bs.setBit(63);
      expect(bs.count(), equals(4));
      bs.setBit(62);
      expect(bs.count(), equals(5));
      bs.setBit(32);
      expect(bs.count(), equals(6));
      bs.setBit(31);
      expect(bs.count(), equals(7));
      bs.setBit(1000);
      expect(bs.count(), equals(8));
      bs.clearAll();
      expect(bs.count(), equals(0));
    });
    
    test("xor [$bitsPerElement]", () {
      expect(new BitSet.fromString("0", bitsPerElement) ^ new BitSet.fromString("0", bitsPerElement), equals(new BitSet.fromString("0")));
      expect(new BitSet.fromString("1", bitsPerElement) ^ new BitSet.fromString("1", bitsPerElement), equals(new BitSet.fromString("0")));
      expect(new BitSet.fromString("0", bitsPerElement) ^ new BitSet.fromString("1", bitsPerElement), equals(new BitSet.fromString("1")));
      expect(new BitSet.fromString("1", bitsPerElement) ^ new BitSet.fromString("0", bitsPerElement), equals(new BitSet.fromString("1")));

      expect(new BitSet.fromString("10", bitsPerElement) ^ new BitSet.fromString("0", bitsPerElement), equals(new BitSet.fromString("10")));
      expect(new BitSet.fromString("11", bitsPerElement) ^ new BitSet.fromString("1", bitsPerElement), equals(new BitSet.fromString("10")));
      expect(new BitSet.fromString("0", bitsPerElement) ^ new BitSet.fromString("10", bitsPerElement), equals(new BitSet.fromString("10")));
      expect(new BitSet.fromString("1", bitsPerElement) ^ new BitSet.fromString("11", bitsPerElement), equals(new BitSet.fromString("10")));

      expect(new BitSet.fromString("10000000000000000000000000000000000000000000000000000000000000000", bitsPerElement) ^ new BitSet.fromString("11000000000000000000000000000000000000000000000000000000000000011", bitsPerElement), equals(new BitSet.fromString("1000000000000000000000000000000000000000000000000000000000000011")));
      expect(new BitSet.fromString("10000000000000000000000000000000000000000000000000000000000000000", bitsPerElement) ^ new BitSet.fromString("1", bitsPerElement), equals(new BitSet.fromString("10000000000000000000000000000000000000000000000000000000000000001")));
      expect(new BitSet.fromString("1", bitsPerElement) ^ new BitSet.fromString("10000000000000000000000000000000000000000000000000000000000000000", bitsPerElement), equals(new BitSet.fromString("10000000000000000000000000000000000000000000000000000000000000001")));
    });
    
    test("and [$bitsPerElement]", () {
      expect(new BitSet.fromString("0", bitsPerElement) & new BitSet.fromString("0", bitsPerElement), equals(new BitSet.fromString("0")));
      expect(new BitSet.fromString("1", bitsPerElement) & new BitSet.fromString("1", bitsPerElement), equals(new BitSet.fromString("1")));
      expect(new BitSet.fromString("0", bitsPerElement) & new BitSet.fromString("1", bitsPerElement), equals(new BitSet.fromString("0")));
      expect(new BitSet.fromString("1", bitsPerElement) & new BitSet.fromString("0", bitsPerElement), equals(new BitSet.fromString("0")));

      expect(new BitSet.fromString("10", bitsPerElement) & new BitSet.fromString("0", bitsPerElement), equals(new BitSet.fromString("")));
      expect(new BitSet.fromString("11", bitsPerElement) & new BitSet.fromString("1", bitsPerElement), equals(new BitSet.fromString("1")));
      expect(new BitSet.fromString("0", bitsPerElement) & new BitSet.fromString("10", bitsPerElement), equals(new BitSet.fromString("")));
      expect(new BitSet.fromString("1", bitsPerElement) & new BitSet.fromString("11", bitsPerElement), equals(new BitSet.fromString("1")));

      expect(new BitSet.fromString("10000000000000000000000000000000000000000000000000000000000000000", bitsPerElement) & new BitSet.fromString("11000000000000000000000000000000000000000000000000000000000000011", bitsPerElement), equals(new BitSet.fromString("10000000000000000000000000000000000000000000000000000000000000000")));
      expect(new BitSet.fromString("10000000000000000000000000000000000000000000000000000000000000000", bitsPerElement) & new BitSet.fromString("1", bitsPerElement), equals(new BitSet.fromString("")));
      expect(new BitSet.fromString("1", bitsPerElement) & new BitSet.fromString("10000000000000000000000000000000000000000000000000000000000000000", bitsPerElement), equals(new BitSet.fromString("")));
    });
    
    test("or [$bitsPerElement]", () {
      expect(new BitSet.fromString("0", bitsPerElement) | new BitSet.fromString("0", bitsPerElement), equals(new BitSet.fromString("0")));
      expect(new BitSet.fromString("1", bitsPerElement) | new BitSet.fromString("1", bitsPerElement), equals(new BitSet.fromString("1")));
      expect(new BitSet.fromString("0", bitsPerElement) | new BitSet.fromString("1", bitsPerElement), equals(new BitSet.fromString("1")));
      expect(new BitSet.fromString("1", bitsPerElement) | new BitSet.fromString("0", bitsPerElement), equals(new BitSet.fromString("1")));

      expect(new BitSet.fromString("10", bitsPerElement) | new BitSet.fromString("0", bitsPerElement), equals(new BitSet.fromString("10")));
      expect(new BitSet.fromString("11", bitsPerElement) | new BitSet.fromString("1", bitsPerElement), equals(new BitSet.fromString("11")));
      expect(new BitSet.fromString("0", bitsPerElement) | new BitSet.fromString("10", bitsPerElement), equals(new BitSet.fromString("10")));
      expect(new BitSet.fromString("1", bitsPerElement) | new BitSet.fromString("11", bitsPerElement), equals(new BitSet.fromString("11")));

      expect(new BitSet.fromString("10000000000000000000000000000000000000000000000000000000000000000", bitsPerElement) | new BitSet.fromString("11000000000000000000000000000000000000000000000000000000000000011", bitsPerElement), equals(new BitSet.fromString("11000000000000000000000000000000000000000000000000000000000000011")));
      expect(new BitSet.fromString("10000000000000000000000000000000000000000000000000000000000000000", bitsPerElement) | new BitSet.fromString("1", bitsPerElement), equals(new BitSet.fromString("10000000000000000000000000000000000000000000000000000000000000001")));
      expect(new BitSet.fromString("1", bitsPerElement) | new BitSet.fromString("10000000000000000000000000000000000000000000000000000000000000000", bitsPerElement), equals(new BitSet.fromString("10000000000000000000000000000000000000000000000000000000000000001")));
    });

    test("not [$bitsPerElement]", () {
      expect(~new BitSet.fromString("0", bitsPerElement), equals(new BitSet.fromString("")));
      expect(~new BitSet.fromString("1", bitsPerElement), equals(new BitSet.fromString("0")));
      expect(~new BitSet.fromString("10", bitsPerElement), equals(new BitSet.fromString("01")));
      expect(~new BitSet.fromString("11", bitsPerElement), equals(new BitSet.fromString("00")));
      expect(~new BitSet.fromString("100000000000000000000000000000000000000000000000000000000000000000000000000001", bitsPerElement), equals(new BitSet.fromString("11111111111111111111111111111111111111111111111111111111111111111111111111110")));
      expect(~new BitSet.fromString("111111111111111111111111111111111111111111111111111111111111111111111111111110", bitsPerElement), equals(new BitSet.fromString("1")));
    });
  }
}

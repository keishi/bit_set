import 'package:unittest/unittest.dart';
import 'package:bitset/bitset.dart';

void main() {
  test("fromString/toString", () {
    expect(new BitSet.fromString("0").toString(), equals(""));
    expect(new BitSet.fromString("1").toString(), equals("1"));
    expect(new BitSet.fromString("101").toString(), equals("101"));
    expect(new BitSet.fromString("0111").toString(), equals("111"));
    expect(new BitSet.fromString("000000000000000000000000000000001").toString(), equals("1"));
    expect(new BitSet.fromString("00000000000000000000000000000000000000000000000000000000000000001").toString(), equals("1"));
    expect(new BitSet.fromString("11000000000000000000000000000000000000000000000000000000000000001").toString(), equals("11000000000000000000000000000000000000000000000000000000000000001"));
  });

  test("equality", () {
    expect(new BitSet.fromString("0"), equals(new BitSet()));
    expect(new BitSet.fromString("0"), equals(new BitSet.fromString("0")));
    expect(new BitSet.fromString("1"), equals(new BitSet.fromString("1")));
    expect(new BitSet.fromString("01"), equals(new BitSet.fromString("1")));
    expect(new BitSet.fromString("1"), equals(new BitSet.fromString("01")));
    expect(new BitSet.fromString("00000000000000000000000000000000000000000000000000000000000000001"), equals(new BitSet.fromString("1")));
    expect(new BitSet.fromString("1"), equals(new BitSet.fromString("00000000000000000000000000000000000000000000000000000000000000001")));
    expect(new BitSet.fromString("110110101100001010101100000011101111110010"), equals(new BitSet.fromString("110110101100001010101100000011101111110010")));
  });

  test("toString", () {
    BitSet bs = new VariableLengthBitSet();
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

  test("toInt", () {
    BitSet bs = new VariableLengthBitSet();
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
  
  test("count", () {
    BitSet bs = new VariableLengthBitSet();
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
  
  test("xor", () {
    expect(new BitSet.fromString("0") ^ new BitSet.fromString("0"), equals(new BitSet.fromString("0")));
    expect(new BitSet.fromString("1") ^ new BitSet.fromString("1"), equals(new BitSet.fromString("0")));
    expect(new BitSet.fromString("0") ^ new BitSet.fromString("1"), equals(new BitSet.fromString("1")));
    expect(new BitSet.fromString("1") ^ new BitSet.fromString("0"), equals(new BitSet.fromString("1")));

    expect(new BitSet.fromString("10") ^ new BitSet.fromString("0"), equals(new BitSet.fromString("10")));
    expect(new BitSet.fromString("11") ^ new BitSet.fromString("1"), equals(new BitSet.fromString("10")));
    expect(new BitSet.fromString("0") ^ new BitSet.fromString("10"), equals(new BitSet.fromString("10")));
    expect(new BitSet.fromString("1") ^ new BitSet.fromString("11"), equals(new BitSet.fromString("10")));

    expect(new BitSet.fromString("10000000000000000000000000000000000000000000000000000000000000000") ^ new BitSet.fromString("11000000000000000000000000000000000000000000000000000000000000011"), equals(new BitSet.fromString("1000000000000000000000000000000000000000000000000000000000000011")));
    expect(new BitSet.fromString("10000000000000000000000000000000000000000000000000000000000000000") ^ new BitSet.fromString("1"), equals(new BitSet.fromString("10000000000000000000000000000000000000000000000000000000000000001")));
    expect(new BitSet.fromString("1") ^ new BitSet.fromString("10000000000000000000000000000000000000000000000000000000000000000"), equals(new BitSet.fromString("10000000000000000000000000000000000000000000000000000000000000001")));
  });
  
  test("and", () {
    expect(new BitSet.fromString("0") & new BitSet.fromString("0"), equals(new BitSet.fromString("0")));
    expect(new BitSet.fromString("1") & new BitSet.fromString("1"), equals(new BitSet.fromString("1")));
    expect(new BitSet.fromString("0") & new BitSet.fromString("1"), equals(new BitSet.fromString("0")));
    expect(new BitSet.fromString("1") & new BitSet.fromString("0"), equals(new BitSet.fromString("0")));

    expect(new BitSet.fromString("10") & new BitSet.fromString("0"), equals(new BitSet.fromString("")));
    expect(new BitSet.fromString("11") & new BitSet.fromString("1"), equals(new BitSet.fromString("1")));
    expect(new BitSet.fromString("0") & new BitSet.fromString("10"), equals(new BitSet.fromString("")));
    expect(new BitSet.fromString("1") & new BitSet.fromString("11"), equals(new BitSet.fromString("1")));

    expect(new BitSet.fromString("10000000000000000000000000000000000000000000000000000000000000000") & new BitSet.fromString("11000000000000000000000000000000000000000000000000000000000000011"), equals(new BitSet.fromString("10000000000000000000000000000000000000000000000000000000000000000")));
    expect(new BitSet.fromString("10000000000000000000000000000000000000000000000000000000000000000") & new BitSet.fromString("1"), equals(new BitSet.fromString("")));
    expect(new BitSet.fromString("1") & new BitSet.fromString("10000000000000000000000000000000000000000000000000000000000000000"), equals(new BitSet.fromString("")));
  });
}

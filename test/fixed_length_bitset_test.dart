import 'package:unittest/unittest.dart';
import 'package:bitset/bitset.dart';

void main() {

  test("fromString/toString", () {
    expect(new FixedLengthBitSet.fromString("0").toString(), equals("0"));
    expect(new FixedLengthBitSet.fromString("1").toString(), equals("1"));
    expect(new FixedLengthBitSet.fromString("101").toString(), equals("101"));
    expect(new FixedLengthBitSet.fromString("0111").toString(), equals("0111"));
    expect(new FixedLengthBitSet.fromString("0001").toString(), equals("0001"));
  });

  test("equality", () {
    expect(new FixedLengthBitSet.fromString("0"), equals(new FixedLengthBitSet(1)));
    expect(new FixedLengthBitSet.fromString("0"), equals(new FixedLengthBitSet.fromString("0")));
    expect(new FixedLengthBitSet.fromString("1"), equals(new FixedLengthBitSet.fromString("1")));
    expect(new FixedLengthBitSet.fromString("01"), equals(new FixedLengthBitSet.fromString("01")));
    // FIXME: Add not equal tests.
  });

  test("setBit/clearBit/flipBit", () {
    BitSet bs = new FixedLengthBitSet(10);
    expect(bs.toString(), equals("0000000000"));
    bs.setBit(0);
    expect(bs.toString(), equals("0000000001"));
    bs.setBit(2);
    expect(bs.toString(), equals("0000000101"));
    bs.setBit(9);
    expect(bs.toString(), equals("1000000101"));

    bs.clearBit(9);
    expect(bs.toString(), equals("0000000101"));
    bs.clearBit(1);
    expect(bs.toString(), equals("0000000101"));
    bs.clearBit(0);
    expect(bs.toString(), equals("0000000100"));

    bs.flipBit(0);
    expect(bs.toString(), equals("0000000101"));
    bs.flipBit(2);
    expect(bs.toString(), equals("0000000001"));
    bs.flipBit(9);
    expect(bs.toString(), equals("1000000001"));
  });

  test("not", () {
    BitSet bs = new FixedLengthBitSet.fromString("10101101110");

    expect((~bs).length, 11);
    expect((~bs).toInt(), equals(657));
    expect((~bs).toString(), equals("01010010001"));

    expect((~(~bs)).length, 11);
    expect((~(~bs)).toInt(), equals(1390));
    expect((~(~bs)).toString(), equals("10101101110"));
  });

}

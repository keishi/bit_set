library bitset;

import 'dart:math';
import 'dart:typed_data';

const bool _SUPPORTS_BIG_INT = (1 << 63) > 0;
const int _CHAR_CODE_0 = 0x30;
const int _CHAR_CODE_1 = 0x31;

abstract class BitSet {
  /**
   * Creates a bit set whose initial size is large enough to explicitly
   * represent bits with indices in the range 0 through `bitCount`-1. All
   * bits are initially false.
   */
  factory BitSet([int bitCount, int bitsPerElement]) => new VariableLengthBitSet(bitCount, bitsPerElement);
  factory BitSet.fromBitSet(BitSet bitSet) => new VariableLengthBitSet.fromBitSet(bitSet);
  factory BitSet.fromString(String binaryString, [int bitsPerElement]) => new VariableLengthBitSet.fromString(binaryString, bitsPerElement);
  BitSet.base();
  /**
   * Sets the bit at `index` to true.
   *
   * @throws RangeError if {@code index < 0}.
   */
  void setBit(int index);
  void clearBit(int index);
  void flipBit(int index);
  void setRange(int start, int end);
  void clearRange(int start, int end);
  void flipRange(int start, int end);
  void setAll();
  void clearAll();
  void flipAll();
  int count();
  int size();
  int get length;
  void set length(int newLength);
  /**
   * Returns true if all bits are unset.
   */
  bool get isEmpty;
  bool operator [](int index);
  void operator []=(int index, bool bit);
  BitSet operator ~();
  BitSet operator ^(BitSet other);
  BitSet operator &(BitSet other);
  BitSet operator |(BitSet other);
  String toString();
  int toInt();
}

abstract class FixedLengthBitSet extends BitSet {
  factory FixedLengthBitSet([bitCount]) => new IntFixedLengthBitSet(bitCount);
  factory FixedLengthBitSet.fromBitSet(BitSet bitSet) => new IntFixedLengthBitSet.fromBitSet(bitSet);
  factory FixedLengthBitSet.fromString(String binaryString, [int bitsPerElement]) => new IntFixedLengthBitSet.fromString(binaryString, bitsPerElement);
  FixedLengthBitSet.base() : super.base();
}

class IntFixedLengthBitSet extends FixedLengthBitSet {
  int _length;
  int _data;
  int _mask;
  IntFixedLengthBitSet([int bitCount = 0]) : super.base() {
    if (!_SUPPORTS_BIG_INT && bitCount > 31) {
      throw new ArgumentError("Bit count ($bitCount) must be <= 31.");
    }
    _data = 0;
    _length = bitCount;
    if (_SUPPORTS_BIG_INT || _length < 31) {
      _mask = (1 << _length) - 1;
    } else {
      _mask = 0;
      for (int i = 0; i < _length; ++i) {
        _mask |= 1 << i;
      }
    }
  }
  factory IntFixedLengthBitSet.fromBitSet(BitSet bitSet) {
    throw new UnimplementedError();
    return null;
  }
  factory IntFixedLengthBitSet.fromString(String binaryString, [int bitsPerElement]) {
    List<int> codeUnits = binaryString.codeUnits;
    int bitCount = codeUnits.length;
    IntFixedLengthBitSet bitSet = new IntFixedLengthBitSet(bitCount);
    for (int i = 0; i < codeUnits.length; i++) {
      int code = codeUnits[i];
      if (code == _CHAR_CODE_1) {
        bitSet[bitCount - i - 1] = true;
      } else if (code != _CHAR_CODE_0) {
        throw new ArgumentError("Binary string ($binaryString) should only contain 0 or 1. Found ${new String.fromCharCode(code)}.");
      }
    }
    return bitSet;
  }
  void setBit(int index) {
    if (index < 0) {
      throw new RangeError("Index ($index) must be greater than or equal to 0.");
    }
    if (index >= _length) {
      throw new RangeError("Index ($index) must be greater than the length ($_length).");
    }
    _data |= 1 << index;
  }
  void clearBit(int index) {
    if (index < 0) {
      throw new RangeError("Index ($index) must be greater than or equal to 0.");
    }
    if (index >= _length) {
      throw new RangeError("Index ($index) must be greater than the length ($_length).");
    }
    _data &= ~(1 << index);
  }
  void flipBit(int index) {
    if (index < 0) {
      throw new RangeError("Index ($index) must be greater than or equal to 0.");
    }
    if (index >= _length) {
      throw new RangeError("Index ($index) must be greater than the length ($_length).");
    }
    _data ^= 1 << index;
  }
  void setRange(int start, int end) {
    for (int i = start; i < end; ++i) {
      setBit(i);
    }
  }
  void clearRange(int start, int end) {
    for (int i = start; i < end; ++i) {
      clearBit(i);
    }
  }
  void flipRange(int start, int end) {
    for (int i = start; i < end; ++i) {
      flipBit(i);
    }
  }
  void setAll() {
    throw new UnimplementedError("");
  }
  void clearAll() {
    _data = 0;
  }
  void flipAll() {
    throw new UnimplementedError("");
  }
  bool get isEmpty => _data == 0;
  int count() {
    int n = _data;
    if (_SUPPORTS_BIG_INT) {
      if (_length <= 32) {
        n -= (n >> 1) & 0x55555555;
        n = (n & 0x33333333) + ((n >> 2) & 0x33333333);
        n = (n + (n >> 4)) & 0x0f0f0f0f;
        return (n * 0x01010101).toUnsigned(32) >> 24;
      }
      if (_length <= 32) {
        n -= (n >> 1) & 0x5555555555555555;
        n = (n & 0x3333333333333333) + ((n >> 2) & 0x3333333333333333);
        n = (n + (n >> 4)) & 0x0f0f0f0f0f0f0f0f;
        return (n * 0x0101010101010101).toUnsigned(64) >> 56;
      }
    } else if (_length <= 16) {
      n -= (n >> 1) & 0x5555;
      n = (n & 0x3333) + ((n >> 2) & 0x3333);
      n = (n + (n >> 4)) & 0x0f0f;
      return (n * 0x0101).toUnsigned(16) >> 8;
    }
    int count = 0;
    while (n != 0) {
      n &= n - 1; // clear the least significant bit set
      count++;
    }
    return count;
  }
  int size() {
    return _length;
  }
  int get length => _length;
  void set length(int newLength) {
    throw new UnimplementedError("Fixed length bit sets do not support setting length");
  }
  bool operator [](int index) {
    if (index < 0) {
      throw new RangeError("Index ($index) must be greater than or equal to 0.");
    }
    if (index >= _length) {
      throw new RangeError("Index ($index) must be greater than the length ($_length).");
    }
    return (_data & (1 << index)) != 0;
  }
  void operator []=(int index, bool bit) {
    if (bit) {
      setBit(index);
    } else {
      clearBit(index);
    }
  }
  BitSet operator ~() {
    IntFixedLengthBitSet result = new IntFixedLengthBitSet(_length);
    result._data = ~_data & _mask;
    return result;
  }
  BitSet operator ^(BitSet other) {
    if (other is IntFixedLengthBitSet) {
      int maxLength = max(_length, other._length);
      IntFixedLengthBitSet result = new IntFixedLengthBitSet(maxLength);
      result._data = _data ^ other._length;
      return result;
    } else {
      throw new UnimplementedError();
    }
  }
  BitSet operator &(BitSet other) {
    if (other is IntFixedLengthBitSet) {
      int maxLength = max(_length, other._length);
      IntFixedLengthBitSet result = new IntFixedLengthBitSet(maxLength);
      result._data = _data & other._length;
      return result;
    } else {
      throw new UnimplementedError();
    }
  }
  BitSet operator |(BitSet other) {
    if (other is IntFixedLengthBitSet) {
      int maxLength = max(_length, other._length);
      IntFixedLengthBitSet result = new IntFixedLengthBitSet(maxLength);
      result._data = _data | other._length;
      return result;
    } else {
      throw new UnimplementedError();
    }
  }
  bool operator ==(BitSet other) {
    int thisLength = length;
    if (thisLength != other.length) {
      return false;
    }
    if (other is IntFixedLengthBitSet) {
      return _data == other._data;
    } else {
      for (int i = 0; i < thisLength; ++i) {
        if (this[i] != other[i]) {
          return false;
        }
      }
    }
    return true;
  }
  String toString() {
    StringBuffer buffer = new StringBuffer();
    String string = _data.toRadixString(2);
    buffer.writeAll(new Iterable.generate(_length - string.length, (i) => "0"));
    buffer.write(string);
    return buffer.toString();
  }
  int toInt() {
    return _data;
  }
}

class VariableLengthBitSet extends BitSet {
  int _bitsPerElement;
  List<int> _elements;
  int _usedElements;
  int _elementBitIndexMask;

  VariableLengthBitSet([int bitCount = 0, int bitsPerElement]) : super.base() {
    if (bitCount == null) {
      bitCount = 0;
    }
    if (bitCount < 0) {
      throw new ArgumentError("Bit count ($bitCount) must be greater than 0.");
    }
    if (bitsPerElement != null) {
      Set<int> supportedBitsPerElement = new Set.from([8, 16, 32, 64]);
      if (!supportedBitsPerElement.contains(bitsPerElement)) {
        throw new ArgumentError("Bits per element ($bitsPerElement) must be one of $supportedBitsPerElement.");
      }
      _bitsPerElement = bitsPerElement;
    } else {
      _bitsPerElement = _SUPPORTS_BIG_INT ? 32 : 16;
    }
    _elements = _arrayForBits(bitCount);
    _bitsPerElement = (_elements as TypedData).elementSizeInBytes * 8;
    _elementBitIndexMask = _createElementBitIndexMask();
    _usedElements = 0;
  }
  factory VariableLengthBitSet.fromBitSet(BitSet bitSet) {
    throw new UnimplementedError();
    return null;
  }
  factory VariableLengthBitSet.fromString(String binaryString, [int bitsPerElement]) {
    List<int> codeUnits = binaryString.codeUnits;
    int bitCount = codeUnits.length;
    VariableLengthBitSet bitSet = new VariableLengthBitSet(bitCount, bitsPerElement);
    for (int i = 0; i < codeUnits.length; i++) {
      int code = codeUnits[i];
      if (code == _CHAR_CODE_1) {
        bitSet[bitCount - i - 1] = true;
      } else if (code != _CHAR_CODE_0) {
        throw new ArgumentError("Binary string ($binaryString) should only contain 0 or 1. Found ${new String.fromCharCode(code)}.");
      }
    }
    return bitSet;
  }
  int _createElementBitIndexMask() {
    if (_bitsPerElement == 64) {
      return 0x3f;
    }
    if (_bitsPerElement == 32) {
      return 0x1f;
    }
    if (_bitsPerElement == 16) {
      return 0xf;
    }
    if (_bitsPerElement == 8) {
      return 0x7;
    }
    assert(false);
    return 0;
  }
  List<int> _arrayForBits(int bitCount) {
    int capacity = ((bitCount + _bitsPerElement - 1)/ _bitsPerElement).floor();
    if (_bitsPerElement == 64) {
      return new Uint64List(capacity);
    }
    if (_bitsPerElement == 32) {
      return new Uint32List(capacity);
    }
    if (_bitsPerElement == 16) {
      return new Uint16List(capacity);
    }
    if (_bitsPerElement == 8) {
      return new Uint32List(capacity);
    }
    assert(false);
    return null;
  }
  void _shrinkSize() {
    int i = _usedElements - 1;
    while (i >= 0 && _elements[i] == 0) {
      --i;
    }
    _usedElements = i + 1;
  }
  void _ensureCapacity(int desiredElementCapacity) {
    if (desiredElementCapacity <= _elements.length) {
      return;
    }
    int newLength = max(desiredElementCapacity, _elements.length * 2);
    Uint64List newBits = new Uint64List(newLength);
    newBits.setAll(0, _elements);
    _elements = newBits;
    // '_usedElements' is unchanged by this operation: the Int64List is larger,
    // but you're not yet using any more of it.
  }
  int _elementBitCount(int elementValue) {
    int n = elementValue;
    if (_bitsPerElement == 64) {
      n -= (n >> 1) & 0x5555555555555555;
      n = (n & 0x3333333333333333) + ((n >> 2) & 0x3333333333333333);
      n = (n + (n >> 4)) & 0x0f0f0f0f0f0f0f0f;
      return (n * 0x0101010101010101).toUnsigned(64) >> 56;
    } else if (_bitsPerElement == 32) {
      n -= (n >> 1) & 0x55555555;
      n = (n & 0x33333333) + ((n >> 2) & 0x33333333);
      n = (n + (n >> 4)) & 0x0f0f0f0f;
      return (n * 0x01010101).toUnsigned(32) >> 24;
    } else if (_bitsPerElement == 16) {
      n -= (n >> 1) & 0x5555;
      n = (n & 0x3333) + ((n >> 2) & 0x3333);
      n = (n + (n >> 4)) & 0x0f0f;
      return (n * 0x0101).toUnsigned(16) >> 8;
    }
    int count = 0;
    while (n != 0) {
      n &= n - 1; // clear the least significant bit set
      count++;
    }
    return count;
  }
  int _bitIndexToElementIndex(int bitIndex) {
    if (_bitsPerElement == 64) {
      return bitIndex >> 6;
    } else if (_bitsPerElement == 32) {
      return bitIndex >> 5;
    } else if (_bitsPerElement == 16) {
      return bitIndex >> 4;
    } else if (_bitsPerElement == 8) {
      return bitIndex >> 3;
    }
    assert(false);
    return 0;
  }
  int _bitIndexToElementBitIndex(int bitIndex) {
    return bitIndex & _elementBitIndexMask;
  }
  void setBit(int index) {
    if (index < 0) {
      throw new RangeError("Index ($index) must be greater than or equal to 0.");
    }
    int elementIndex = _bitIndexToElementIndex(index);
    if (elementIndex >= _elements.length) {
      _ensureCapacity(elementIndex + 1);
    }
    _elements[elementIndex] |= 1 << _bitIndexToElementBitIndex(index);
    _usedElements = max(_usedElements, elementIndex + 1);
  }
  void clearBit(int index) {
    if (index < 0) {
      throw new RangeError("Index ($index) must be greater than or equal to 0.");
    }
    int elementIndex = _bitIndexToElementIndex(index);
    if (elementIndex >= _elements.length) {
      return;
    }
    _elements[elementIndex] &= ~(1 << _bitIndexToElementBitIndex(index));
    _shrinkSize();
  }
  void flipBit(int index) {
    if (index < 0) {
      throw new RangeError("Index ($index) must be greater than or equal to 0.");
    }
    int elementIndex = _bitIndexToElementIndex(index);
    if (elementIndex >= _elements.length) {
      _ensureCapacity(elementIndex + 1);
    }
    _elements[elementIndex] ^= (1 << _bitIndexToElementBitIndex(index));
    _usedElements = max(_usedElements, elementIndex + 1);
    _shrinkSize();
  }
  void setRange(int start, int end) {
    for (int i = start; i < end; ++i) {
      setBit(i);
    }
  }
  void clearRange(int start, int end) {
    for (int i = start; i < end; ++i) {
      clearBit(i);
    }
  }
  void flipRange(int start, int end) {
    for (int i = start; i < end; ++i) {
      flipBit(i);
    }
  }
  void setAll() {
    throw new UnimplementedError();
  }
  void clearAll() {
    _elements.fillRange(0, _usedElements, 0);
    _usedElements = 0;
  }
  void flipAll() {
    throw new UnimplementedError();
  }
  bool get isEmpty {
    for (int i = 0; i < _usedElements; ++i) {
      if (_elements[i] != 0) {
        return false;
      }
    }
    return true;
  }
  int count() {
    var result = _elements.fold(0, (s, e) => s + _elementBitCount(e));
    return result;
  }
  int size() {
    return _elements.length * _bitsPerElement;
  }
  int get length {
    if (_usedElements == 0) {
      return 0;
    }
    return _bitsPerElement * (_usedElements - 1) + _elements[_usedElements - 1].bitLength;
  }
  void set length(int newLength) {
    throw new UnimplementedError();
  }
  bool operator [](int index) {
    if (index < 0) {
      throw new RangeError("Index ($index) must be greater than or equal to 0.");
    }
    int elementIndex = _bitIndexToElementIndex(index);
    if (elementIndex >= _usedElements) {
      return false;
    }
    return (_elements[elementIndex] & (1 << _bitIndexToElementBitIndex(index))) != 0;
  }
  void operator []=(int index, bool bit) {
    if (bit) {
      setBit(index);
    } else {
      clearBit(index);
    }
  }
  BitSet operator ~() {
    VariableLengthBitSet result = new VariableLengthBitSet(this.length, _bitsPerElement);
    result._usedElements = _usedElements;
    int mask = (1 << _bitsPerElement) - 1;
    for (int i = 0; i < _usedElements; ++i) {
      result._elements[i] = ~_elements[i] & mask;
    }
    if (_usedElements > 0) {
      int lastElementBitLength = _elements[_usedElements - 1].bitLength;
      mask = (1 << lastElementBitLength) - 1;
      result._elements[_usedElements - 1] &= mask;
    }
    result._shrinkSize();
    return result;
  }
  BitSet operator ^(BitSet other) {
    if (other is VariableLengthBitSet && _bitsPerElement == other._bitsPerElement) {
      int minElementSize = (min(size(), other.size()) / _bitsPerElement).floor();
      int maxSize = max(size(), other.size());
      int maxElementSize = (maxSize / _bitsPerElement).floor();
      VariableLengthBitSet result = new VariableLengthBitSet(maxSize, _bitsPerElement);
      for (int i = 0; i < minElementSize; ++i) {
        result._elements[i] = _elements[i] ^ other._elements[i];
      }
      if (other._usedElements > minElementSize) {
        result._elements.setRange(minElementSize, maxElementSize, other._elements, minElementSize);
      } else if (_usedElements > minElementSize) {
        result._elements.setRange(minElementSize, maxElementSize, _elements, minElementSize);
      }
      result._usedElements = maxElementSize;
      result._shrinkSize();
      return result;
    } else {
      throw new UnimplementedError();
    }
  }
  BitSet operator &(BitSet other) {
    if (other is VariableLengthBitSet && _bitsPerElement == other._bitsPerElement) {
      int minElementSize = (min(size(), other.size()) / _bitsPerElement).floor();
      int maxSize = max(size(), other.size());
      int maxElementSize = (maxSize / _bitsPerElement).floor();
      VariableLengthBitSet result = new VariableLengthBitSet(maxSize, _bitsPerElement);
      for (int i = 0; i < minElementSize; ++i) {
        result._elements[i] = _elements[i] & other._elements[i];
      }
      result._usedElements = maxElementSize;
      result._shrinkSize();
      return result;
    } else {
      throw new UnimplementedError();
    }
  }
  BitSet operator |(BitSet other) {
    if (other is VariableLengthBitSet && _bitsPerElement == other._bitsPerElement) {
      int minElementSize = (min(size(), other.size()) / _bitsPerElement).floor();
      int maxSize = max(size(), other.size());
      int maxElementSize = (maxSize / _bitsPerElement).floor();
      VariableLengthBitSet result = new VariableLengthBitSet(maxSize, _bitsPerElement);
      for (int i = 0; i < minElementSize; ++i) {
        result._elements[i] = _elements[i] | other._elements[i];
      }
      if (other._usedElements > minElementSize) {
        result._elements.setRange(minElementSize, maxElementSize, other._elements, minElementSize);
      } else if (_usedElements > minElementSize) {
        result._elements.setRange(minElementSize, maxElementSize, _elements, minElementSize);
      }
      result._usedElements = maxElementSize;
      result._shrinkSize();
      return result;
    } else {
      throw new UnimplementedError();
    }
  }
  bool operator ==(BitSet other) {
    int thisLength = length;
    if (thisLength != other.length) {
      return false;
    }
    if (other is VariableLengthBitSet && _bitsPerElement == other._bitsPerElement) {
      for (int i = 0; i < _usedElements; ++i) {
        if (this._elements[i] != other._elements[i]) {
          return false;
        }
      }
    } else {
      for (int i = 0; i < thisLength; ++i) {
        if (this[i] != other[i]) {
          return false;
        }
      }
    }
    return true;
  }
  String toString() {
    if (_usedElements == 0) {
      return "";
    }
    StringBuffer buffer = new StringBuffer();
    buffer.write(_elements[_usedElements - 1].toRadixString(2));
    final String padding = new List.filled(_bitsPerElement, "0").join("");
    for (int i = _usedElements - 2; i >= 0; --i) {
      String string = _elements[i].toRadixString(2);
      buffer.writeAll(new Iterable.generate(_bitsPerElement - string.length, (i) => "0"));
      buffer.write(string);
    }
    return buffer.toString();
  }
  int toInt() {
    if (_usedElements == 0) {
      return 0;
    }
    int result = 0;
    for (int i = 0; i < _usedElements; ++i) {
      result |= _elements[i] << (i * _bitsPerElement);
    }
    return result;
  }
}

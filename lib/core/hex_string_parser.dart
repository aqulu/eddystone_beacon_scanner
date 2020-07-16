extension HexStringParser on int {
  ///
  /// Converts an 8bit [int] to it's hexadecimal representation.
  /// if the result is shorter than 2 digits, the string will be prepended with zeroes
  ///
  /// throws a [FormatException] if the string representation is longer than 2 digits
  ///
  String toHexString() {
    if (bitLength > 8) {
      throw FormatException(
        "string representation is longer than 2 digits",
      );
    }

    final radixString = toRadixString(16);
    return radixString.length == 1 ? "0$radixString" : radixString;
  }
}

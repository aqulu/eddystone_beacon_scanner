import 'package:eddystone_beacon_scanner/core/hex_string_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'when bitLength greater than 8 throws FormatException',
    () {
      final value = 256;
      expect(
        () => value.toHexString(),
        throwsA(isInstanceOf<FormatException>()),
      );
    },
  );

  test(
    'prepends single character representations with 0',
    () {
      final value = 0x0E;
      expect(value.toHexString(), "0e");
    },
  );
}

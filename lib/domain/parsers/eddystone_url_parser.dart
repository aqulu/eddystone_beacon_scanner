import 'dart:math';
import 'dart:typed_data';

import 'package:eddystone_beacon_scanner/domain/eddystone.dart';

extension EddystoneUrlParser on Uint8List {
  /// parses this [Uint8List] to an [EddystoneUrl] instance
  ///
  /// throws a [FormatException] if the advertised frame does not match the Eddystone-Url format
  /// or, if [suppressErrors] is true, returns [null] instead of throwing
  EddystoneUrl toEddystoneUrl({bool suppressErrors = false}) {
    final returnNullOrThrow = (String message) =>
        (suppressErrors) ? null : throw FormatException(message);

    if (elementAt(0) != EddystoneUrl.frameType) {
      return returnNullOrThrow(
        "Eddystone-Url frameType should be ${EddystoneUrl.frameType} "
        "but was ${elementAt(0)}}",
      );
    }

    if (length < EddystoneUrl.minFrameLength ||
        length > EddystoneUrl.maxFrameLength) {
      return returnNullOrThrow(
        "payload does not match the Eddystone-Url frame-length\n"
        "should be between ${EddystoneUrl.minFrameLength} and "
        "${EddystoneUrl.maxFrameLength} but was $length",
      );
    }

    final urlSchemePrefix = _urlSchemePrefixes[elementAt(2)];
    if (urlSchemePrefix == null) {
      return returnNullOrThrow(
        "invalid urlScheme: ${elementAt(2)}. should be one "
        "of ${_urlSchemePrefixes.keys.toList()}",
      );
    }

    final url = sublist(3, min(length, EddystoneUrl.maxFrameLength))
        .map(_decode)
        .where((it) => it != null)
        .join();

    return EddystoneUrl(
      txPower: elementAt(1).toSigned(8),
      url: urlSchemePrefix + url,
    );
  }

  /// ref: https://github.com/google/eddystone/tree/master/eddystone-url#url-scheme-prefix
  static const Map<int, String> _urlSchemePrefixes = {
    0x00: "http://www.",
    0x01: "https://www.",
    0x02: "http://",
    0x03: "https://",
  };

  /// decodes an 8bit integer as specified by Eddystone-URL HTTP URL encoding
  /// https://github.com/google/eddystone/tree/master/eddystone-url#eddystone-url-http-url-encoding
  static String _decode(int charCode) => (_isSpecialCharacter(charCode))
      ? _specialCharacters[charCode]
      : String.fromCharCode(charCode);

  static bool _isSpecialCharacter(int charCode) =>
      charCode >= 0x00 && charCode <= 0x20 ||
      charCode >= 0x7F && charCode <= 0xFF;

  static const Map<int, String> _specialCharacters = {
    0x00: ".com/",
    0x01: ".org/",
    0x02: ".edu/",
    0x03: ".net/",
    0x04: ".info/",
    0x05: ".biz/",
    0x06: ".gov/",
    0x07: ".com",
    0x08: ".org",
    0x09: ".edu",
    0x0a: ".net",
    0x0b: ".info",
    0x0c: ".biz",
    0x0d: ".gov",
  };
}

import 'dart:typed_data';

import 'package:eddystone_beacon_scanner/core/hex_string_parser.dart';
import 'package:eddystone_beacon_scanner/domain/eddystone.dart';

extension EddystoneEidParser on Uint8List {
  /// parses this [Uint8List] to an [EddystoneEid] instance
  ///
  /// throws a [FormatException] if the advertised frame does not match the Eddystone-Eid format
  /// or, if [suppressErrors] is true, returns [null] instead of throwing
  EddystoneEid toEddystoneEid({bool suppressErrors = false}) {
    final returnNullOrThrow = (String message) =>
        (suppressErrors) ? null : throw FormatException(message);

    if (elementAt(0) != EddystoneEid.frameType) {
      return returnNullOrThrow(
        "Eddystone-Eid frameType should be ${EddystoneEid.frameType} "
        "but was ${elementAt(0)}}",
      );
    }

    if (length != EddystoneEid.frameLength) {
      return returnNullOrThrow(
        "payload does not match the Eddystone-Eid frame-length\n"
        "should be ${EddystoneEid.frameLength} but was $length",
      );
    }

    return EddystoneEid(
      txPower: elementAt(1).toSigned(8),
      eid: sublist(2, 10).map(parseToHexString).join(),
    );
  }
}

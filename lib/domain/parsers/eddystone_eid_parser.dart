import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:eddystone_beacon_scanner/core/hex_string_parser.dart';
import 'package:eddystone_beacon_scanner/domain/eddystone.dart';

extension EddystoneEidParser on Uint8List {
  /// parses this [Uint8List] to an [EddystoneEid] instance
  ///
  /// returns [FormatException] as [Left] if the advertised frame does not match the Eddystone-Eid format
  /// or the successfully parsed [EddystoneEid] as [Right]
  Either<FormatException, EddystoneEid> toEddystoneEid() {
    if (elementAt(0) != EddystoneEid.frameType) {
      return left(FormatException(
        "Eddystone-Eid frameType should be ${EddystoneEid.frameType} "
        "but was ${elementAt(0)}}",
      ));
    }

    if (length != EddystoneEid.frameLength) {
      return left(FormatException(
        "payload does not match the Eddystone-Eid frame-length\n"
        "should be ${EddystoneEid.frameLength} but was $length",
      ));
    }

    return right(EddystoneEid(
      txPower: elementAt(1).toSigned(8),
      eid: sublist(2, 10).map(parseToHexString).join(),
    ));
  }
}

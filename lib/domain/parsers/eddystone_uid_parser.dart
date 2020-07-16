import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:eddystone_beacon_scanner/core/hex_string_parser.dart';
import 'package:eddystone_beacon_scanner/domain/eddystone.dart';

extension EddystoneUidParser on Uint8List {
  /// parses [AdvertisementData] serviceData that matches the first
  /// [AdvertisementData.serviceUuids] entry to an [EddystoneUid] instance
  ///
  /// returns [FormatException] as [Left] if the advertised frame does not match the Eddystone-Uid format
  /// or the successfully parsed [EddystoneUid] as [Right]
  Either<FormatException, EddystoneUid> toEddystoneUid() {
    if (elementAt(0) != EddystoneUid.frameType) {
      return left(FormatException(
        "Eddystone-uid frameType should be 0x00 but was ${elementAt(0)}}",
      ));
    }

    if (length != EddystoneUid.frameLength &&
        length != EddystoneUid.frameLengthWithReservedBytes) {
      return left(FormatException(
        "payload does not match the Eddystone-Uid frame-length\n"
        "should be ${EddystoneUid.frameLength} or "
        "${EddystoneUid.frameLengthWithReservedBytes} but was $length",
      ));
    }

    return right(EddystoneUid(
      txPower: elementAt(1).toSigned(8),
      namespace: sublist(2, 12).map(parseToHexString).join(),
      instance: sublist(12, 18).map(parseToHexString).join(),
    ));
  }
}

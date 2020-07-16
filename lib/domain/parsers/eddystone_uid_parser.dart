import 'dart:typed_data';

import 'package:eddystone_beacon_scanner/core/hex_string_parser.dart';
import 'package:eddystone_beacon_scanner/domain/eddystone.dart';
import 'package:flutter_ble_lib/flutter_ble_lib.dart';

extension EddystoneUidParser on Uint8List {
  /// parses [AdvertisementData] serviceData that matches the first
  /// [AdvertisementData.serviceUuids] entry to an [EddystoneUid] instance
  ///
  /// throws a [FormatException] if the advertised frame does not match the Eddystone-Uid format
  /// or, if [suppressErrors] is true, returns [null] instead of throwing
  EddystoneUid toEddystoneUid({bool suppressErrors = false}) {
    final returnNullOrThrow = (String message) =>
        (suppressErrors) ? null : throw FormatException(message);

    if (elementAt(0) != EddystoneUid.frameType) {
      return returnNullOrThrow(
        "Eddystone-uid frameType should be 0x00 but was ${elementAt(0)}}",
      );
    }

    if (length != EddystoneUid.frameLength &&
        length != EddystoneUid.frameLengthWithReservedBytes) {
      return returnNullOrThrow(
        "payload does not match the Eddystone-Uid frame-length\n"
        "should be ${EddystoneUid.frameLength} or "
        "${EddystoneUid.frameLengthWithReservedBytes} but was $length",
      );
    }
    return EddystoneUid(
      txPower: elementAt(1).toSigned(8),
      namespace: sublist(2, 12).map((b) => b.toHexString()).join(),
      instance: sublist(12, 18).map((b) => b.toHexString()).join(),
    );
  }
}

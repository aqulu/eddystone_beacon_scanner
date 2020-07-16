import 'package:eddystone_beacon_scanner/core/hex_string_parser.dart';
import 'package:eddystone_beacon_scanner/domain/eddystone.dart';
import 'package:flutter_ble_lib/flutter_ble_lib.dart';

extension EddystoneUidParser on AdvertisementData {
  /// parses [AdvertisementData] serviceData that matches the first
  /// [AdvertisementData.serviceUuids] entry to an [EddystoneUid] instance
  ///
  /// throws a [FormatException] if the advertised frame does not match the Eddystone-Uid format
  /// or, if [suppressErrors] is true, returns [null] instead of throwing
  EddystoneUid toEddystoneUid({bool suppressErrors = false}) {
    final returnNullOrThrow = (String message) =>
        (suppressErrors) ? null : throw FormatException(message);

    if (serviceUuids == null || serviceUuids.isEmpty) {
      return returnNullOrThrow(
        "AdvertisementData $this does not contain any "
        "serviceUuid data",
      );
    }

    final serviceUuid = serviceUuids.first;
    final frame = serviceData[serviceUuid];

    if (frame == null) {
      return returnNullOrThrow(
        "AdvertisementData $this does not contain any "
        "serviceData associated with serviceUuid $serviceUuid",
      );
    } else if (frame.length != EddystoneUid.frameLength &&
        frame.length != EddystoneUid.frameLengthWithReservedBytes) {
      return returnNullOrThrow(
        "ServiceData associated with serviceUuid $serviceUuid does not match "
        "the Eddystone-Uid frame-length\n"
        "should be ${EddystoneUid.frameLength} or "
        "${EddystoneUid.frameLengthWithReservedBytes} but was ${frame.length}",
      );
    }

    if (frame[0] != EddystoneUid.frameType) {
      return returnNullOrThrow(
        "Eddystone-uid frameType should be 0x00 but was ${frame[0]}}",
      );
    }

    return EddystoneUid(
      txPower: frame[1].toSigned(8),
      namespace: frame.sublist(2, 12).map((b) => b.toHexString()).join(),
      instance: frame.sublist(12, 18).map((b) => b.toHexString()).join(),
    );
  }
}

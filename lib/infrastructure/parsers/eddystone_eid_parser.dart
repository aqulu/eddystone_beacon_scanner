import 'package:eddystone_beacon_scanner/core/hex_string_parser.dart';
import 'package:eddystone_beacon_scanner/domain/eddystone.dart';
import 'package:flutter_ble_lib/flutter_ble_lib.dart';

extension EddystoneEidParser on AdvertisementData {
  /// parses [AdvertisementData] serviceData that matches the first
  /// [AdvertisementData.serviceUuids] entry to an [EddystoneEid] instance
  ///
  /// throws a [FormatException] if the advertised frame does not match the Eddystone-Eid format
  /// or, if [suppressErrors] is true, returns [null] instead of throwing
  EddystoneEid toEddystoneEid({bool suppressErrors = false}) {
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
    } else if (frame.length != EddystoneEid.frameLength) {
      return returnNullOrThrow(
        "ServiceData associated with serviceUuid $serviceUuid does not match "
        "the Eddystone-Eid frame-length\n"
        "should be ${EddystoneEid.frameLength} but was ${frame.length}",
      );
    }

    if (frame[0] != EddystoneEid.frameType) {
      return returnNullOrThrow(
        "Eddystone-Eid frameType should be 0x30 but was ${frame[0]}}",
      );
    }

    return EddystoneEid(
      txPower: frame[1].toSigned(8),
      eid: frame.sublist(2, 10).map((b) => b.toHexString()).join(),
    );
  }
}

import 'package:eddystone_beacon_scanner/domain/eddystone_uid.dart';
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
      txPower: frame[1],
      namespace:
          frame.sublist(2, 12).map((b) => b.to2DigitRadix16String()).join(),
      instance:
          frame.sublist(12, 18).map((b) => b.to2DigitRadix16String()).join(),
    );
  }
}

extension _Radix16StringParser on int {
  ///
  /// Converts this to a Radix 16 String representation.
  /// if the result is shorter than 2 digits, the string will be prepended with zeroes
  ///
  /// throws a [FormatException] if the string representation is longer than 2 digits
  ///
  String to2DigitRadix16String() {
    final radixString = toRadixString(16);
    switch (radixString.length) {
      case 1:
        return "0$radixString";
      case 2:
        return radixString;
      default:
        throw FormatException("string representation is longer than 2 digits");
    }
  }
}

import 'package:eddystone_beacon_scanner/domain/eddystone_uid.dart';
import 'package:flutter_ble_lib/flutter_ble_lib.dart';

extension EddystoneUidParser on AdvertisementData {
  /// similar to [AdvertisementData.toEddystoneUid] but returns [null] instead of throwing a
  /// [FormatException]
  EddystoneUid tryParseToEddystoneUid() {
    try {
      return toEddystoneUid();
    } catch (formatException) {
      return null;
    }
  }

  /// parses [AdvertisementData] serviceData that matches the first
  /// [AdvertisementData.serviceUuids] entry to an [EddystoneUid] instance
  /// throws a [FormatException] if the advertised frame does not match the Eddystone-Uid format
  EddystoneUid toEddystoneUid() {
    if (serviceUuids == null || serviceUuids.isEmpty) {
      throw FormatException(
        "AdvertisementData $this does not contain any "
        "serviceUuid data",
      );
    }

    final serviceUuid = serviceUuids.first;
    final frame = serviceData[serviceUuid];

    if (frame == null) {
      throw FormatException(
        "AdvertisementData $this does not contain any "
        "serviceData associated with serviceUuid $serviceUuid",
      );
    } else if (frame.length != EddystoneUid.frameLength &&
        frame.length != EddystoneUid.frameLengthWithReservedBytes) {
      throw FormatException(
        "ServiceData associated with serviceUuid $serviceUuid does not match "
        "the Eddystone-Uid frame-length\n"
        "should be ${EddystoneUid.frameLength} or "
        "${EddystoneUid.frameLengthWithReservedBytes} but was ${frame.length}",
      );
    }

    return EddystoneUid(
      frameType: frame[0],
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

import 'dart:typed_data';

import 'package:eddystone_beacon_scanner/domain/eddystone.dart';
import 'package:eddystone_beacon_scanner/domain/parsers/eddystone_uid_parser.dart';
import 'package:eddystone_beacon_scanner/infrastructure/ble_manager_safe_scan.dart';
import 'package:flutter_ble_lib/flutter_ble_lib.dart';

class EddystoneScanner {
  final BleManager _bleManager;

  const EddystoneScanner(this._bleManager);

  /// start BLE scan and transforms scanResults into [EddystoneUid]s
  Stream<EddystoneUid> scan() => _bleManager.scan().map(
        (scanResult) {
          final payload = scanResult.advertisementData?.payload;
          return payload?.toEddystoneUid(suppressErrors: true);
        },
      ).where((event) => event != null);
}

extension _AdvertisementDataPayload on AdvertisementData {
  /// returns the serviceData that matches the first
  /// [AdvertisementData.serviceUuids] entry, or null if not applicable
  Uint8List get payload => (serviceUuids != null && serviceUuids.isNotEmpty)
      ? serviceData[serviceUuids.first]
      : null;
}

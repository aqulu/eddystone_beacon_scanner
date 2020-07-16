import 'dart:typed_data';

import 'package:eddystone_beacon_scanner/domain/eddystone.dart';
import 'package:eddystone_beacon_scanner/domain/scan_result.dart';
import 'package:eddystone_beacon_scanner/infrastructure/ble_manager_safe_scan.dart';
import 'package:flutter_ble_lib/flutter_ble_lib.dart'
    show BleManager, AdvertisementData;

class EddystoneScanner {
  final BleManager _bleManager;

  const EddystoneScanner(this._bleManager);

  /// start BLE scan and transforms scanResults into [EddystoneUid]s
  Stream<ScanResult> scan() => _bleManager.scan().map(
        (scanResult) {
          final payload = EddystonePayload.parse(
            scanResult.advertisementData?.payload ?? [],
          );

          return (payload != null)
              ? ScanResult(
                  rssi: scanResult.rssi,
                  payload: payload,
                )
              : null;
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

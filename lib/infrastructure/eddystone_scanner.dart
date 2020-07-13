import 'package:eddystone_beacon_scanner/domain/eddystone_uid.dart';
import 'package:eddystone_beacon_scanner/infrastructure/ble_manager_safe_scan.dart';
import 'package:eddystone_beacon_scanner/infrastructure/eddystone_uid_parser.dart';
import 'package:flutter_ble_lib/flutter_ble_lib.dart';

class EddystoneScanner {
  final BleManager _bleManager;

  const EddystoneScanner(this._bleManager);

  /// start BLE scan and transforms scanResults into [EddystoneUid]s
  Stream<EddystoneUid> scan() => _bleManager.scan().map(
        (scanResult) {
          return scanResult.advertisementData?.toEddystoneUid(
            suppressErrors: true,
          );
        },
      ).where((event) => event != null);
}

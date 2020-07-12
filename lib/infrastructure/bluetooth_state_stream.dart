import 'dart:async';

import 'package:eddystone_beacon_scanner/domain/device_state.dart';
import 'package:flutter_ble_lib/flutter_ble_lib.dart' as ble;

class BluetoothStateStream extends StreamView<BluetoothState> {
  BluetoothStateStream(ble.BleManager bleManager)
      : super(
          bleManager
              .observeBluetoothState(emitCurrentValue: true)
              .map((state) => state.toDeviceBluetoothState()),
        );
}

extension BluetoothStateParser on ble.BluetoothState {
  BluetoothState toDeviceBluetoothState() {
    switch (this) {
      case ble.BluetoothState.UNAUTHORIZED:
        return BluetoothState.noPermissions;
      case ble.BluetoothState.POWERED_ON:
        return BluetoothState.on;
      case ble.BluetoothState.POWERED_OFF:
        return BluetoothState.off;
      default:
        return BluetoothState.unknown;
    }
  }
}

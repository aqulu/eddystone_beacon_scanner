import 'package:flutter/foundation.dart';

/// a representation of the current state of Bluetooth and Location services
/// on the device
@immutable
class DeviceState {
  final BluetoothState bluetoothState;
  final LocationServicesState locationServicesState;

  const DeviceState({
    @required this.bluetoothState,
    @required this.locationServicesState,
  });

  bool get canPerformBleScan =>
      bluetoothState == BluetoothState.on &&
      [LocationServicesState.notRequired, LocationServicesState.on]
          .contains(locationServicesState);
}

enum BluetoothState {
  noPermissions,
  off,
  on,
}

enum LocationServicesState {
  /// Android requires Location to be on for ble scan, while ios does not
  notRequired,

  /// permission was never requested before
  permissionUndetermined,

  /// permission has been denied
  permissionDenied,

  /// permission has been denied permanently
  permissionPermanentlyDenied,

  /// location service is off
  off,

  /// location service is on
  on,
}
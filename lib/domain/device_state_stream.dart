import 'dart:async';

import 'package:eddystone_beacon_scanner/domain/device_state.dart';
import 'package:stream_transform/stream_transform.dart' show CombineLatest;

/// combines [BluetoothState] and [LocationServicesState] to a stream of [DeviceState]
class DeviceStateStream extends StreamView<DeviceState> {
  const DeviceStateStream._(Stream<DeviceState> stream) : super(stream);

  factory DeviceStateStream.from(
    Stream<BluetoothState> bluetoothStateStream,
    Stream<LocationServicesState> locationServicesStateStream,
  ) =>
      DeviceStateStream._(
        bluetoothStateStream.combineLatest(
          locationServicesStateStream,
          (bluetoothState, locationServicesState) => DeviceState(
            bluetoothState: bluetoothState,
            locationServicesState: locationServicesState,
          ),
        ),
      );
}

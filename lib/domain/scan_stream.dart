import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:eddystone_beacon_scanner/core/timed_cache_transformer.dart';
import 'package:eddystone_beacon_scanner/domain/device_state.dart';
import 'package:eddystone_beacon_scanner/domain/eddystone.dart';
import 'package:eddystone_beacon_scanner/domain/scan_result.dart';
import 'package:eddystone_beacon_scanner/infrastructure/eddystone_scanner.dart';
import 'package:rxdart/rxdart.dart';
import 'package:stream_transform/stream_transform.dart' show CombineLatest;

/// a stream emitting [DeviceState] as left, if permissions or service state are insufficient for performing BLE scan,
/// or a continuously updated list of [EddystoneUid]s as right, when scanning is in progress
class ScanStream extends StreamView<Either<DeviceState, List<ScanResult>>> {
  const ScanStream._(Stream<Either<DeviceState, List<ScanResult>>> stream)
      : super(stream);

  factory ScanStream(
    Stream<BluetoothState> bluetoothStateStream,
    Stream<LocationServicesState> locationServicesStateStream,
    EddystoneScanner eddystoneScanner,
  ) =>
      ScanStream.from(
        DeviceStateStream.from(
          bluetoothStateStream,
          locationServicesStateStream,
        ),
        eddystoneScanner,
      );

  factory ScanStream.from(
    Stream<DeviceState> deviceStateStream,
    EddystoneScanner eddystoneScanner,
  ) {
    final Stream<Either<DeviceState, List<ScanResult>>> scanStream =
        deviceStateStream.distinct().switchMap(
              (deviceState) => !deviceState.canPerformBleScan
                  ? Stream.value(left(deviceState))
                  : eddystoneScanner
                      .scan()
                      .cacheFor(
                        Duration(seconds: 10),
                        shouldPreventDuplicates: true,
                      )
                      .startWith([]).map(right),
            );
    return ScanStream._(scanStream);
  }
}

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

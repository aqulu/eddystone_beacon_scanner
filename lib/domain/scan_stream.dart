import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:eddystone_beacon_scanner/core/timed_cache_transformer.dart';
import 'package:eddystone_beacon_scanner/domain/device_state.dart';
import 'package:eddystone_beacon_scanner/domain/eddystone_uid.dart';
import 'package:eddystone_beacon_scanner/infrastructure/eddystone_scanner.dart';
import 'package:rxdart/rxdart.dart';

/// a stream emitting [DeviceState] as left, if permissions or service state are insufficient for performing BLE scan,
/// or a continuously updated list of [EddystoneUid]s as right, when scanning is in progress
class ScanStream extends StreamView<Either<DeviceState, List<EddystoneUid>>> {
  const ScanStream._(Stream<Either<DeviceState, List<EddystoneUid>>> stream)
      : super(stream);

  factory ScanStream.from(
    Stream<BluetoothState> bluetoothStateStream,
    Stream<LocationServicesState> locationServicesStateStream,
    EddystoneScanner eddystoneScanner,
  ) {
    final deviceStateStream = CombineLatestStream.combine2(
      bluetoothStateStream,
      locationServicesStateStream,
      (bluetoothState, locationServicesState) => DeviceState(
        bluetoothState: bluetoothState,
        locationServicesState: locationServicesState,
      ),
    );

    final scanStream = deviceStateStream.distinct().switchMap(
          (deviceState) => !deviceState.canPerformBleScan
              ? Stream.value(left<DeviceState, List<EddystoneUid>>(deviceState))
              : eddystoneScanner
                  .scan()
                  .cacheFor(
                    Duration(seconds: 10),
                    shouldPreventDuplicates: true,
                  )
                  .map((it) => right<DeviceState, List<EddystoneUid>>(it)),
        );

    return ScanStream._(scanStream);
  }
}

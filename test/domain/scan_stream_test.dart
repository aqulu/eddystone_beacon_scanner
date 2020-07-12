import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:eddystone_beacon_scanner/domain/device_state.dart';
import 'package:eddystone_beacon_scanner/domain/eddystone_uid.dart';
import 'package:eddystone_beacon_scanner/domain/scan_stream.dart';
import 'package:eddystone_beacon_scanner/infrastructure/eddystone_scanner.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:rxdart/rxdart.dart';

class ScannerMock extends Mock implements EddystoneScanner {}

void main() {
  final scanner = ScannerMock();

  test('when locationServices other than ON emits Left', () async {
    final states = [
      LocationServicesState.off,
      LocationServicesState.permissionUndetermined,
      LocationServicesState.permissionDenied,
      LocationServicesState.permissionPermanentlyDenied,
    ];

    expectLater(
      ScanStream.from(
        Stream.fromIterable(
          states.map(
            (it) => DeviceState(
              locationServicesState: it,
              bluetoothState: BluetoothState.on,
            ),
          ),
        ),
        scanner,
      ),
      emitsInOrder(
        states
            .map(
              (locationServicesState) => left(
                DeviceState(
                  bluetoothState: BluetoothState.on,
                  locationServicesState: locationServicesState,
                ),
              ),
            )
            .toList(),
      ),
    );
  });

  test('when bluetooth other than ON emits Left', () async {
    final states = [
      BluetoothState.unknown,
      BluetoothState.noPermissions,
      BluetoothState.off,
    ];

    expectLater(
      ScanStream.from(
        Stream.fromIterable(
          states.map(
            (it) => DeviceState(
              locationServicesState: LocationServicesState.on,
              bluetoothState: it,
            ),
          ),
        ),
        scanner,
      ),
      emitsInOrder(
        states
            .map(
              (bluetoothState) => left(
                DeviceState(
                  bluetoothState: bluetoothState,
                  locationServicesState: LocationServicesState.on,
                ),
              ),
            )
            .toList(),
      ),
    );
  });

  test(
    'when bluetooth state changed from off to on, starts ble scan',
    () async {
      when(scanner.scan()).thenAnswer((_) => Stream.fromIterable(_scanResults));

      expect(
        ScanStream.from(
          Stream.fromIterable(
            [BluetoothState.off, BluetoothState.on].map(
              (it) => DeviceState(
                locationServicesState: LocationServicesState.on,
                bluetoothState: it,
              ),
            ),
          ),
          scanner,
        ),
        emitsInOrder([
          left(DeviceState(
            bluetoothState: BluetoothState.off,
            locationServicesState: LocationServicesState.on,
          )),
          predicate(
            (Either<dynamic, List<EddystoneUid>> actual) => listEquals(
              _scanResults.getRange(0, 1).toList(),
              actual.getOrElse(() => null),
            ),
          ),
          predicate(
            (Either<dynamic, List<EddystoneUid>> actual) => listEquals(
              _scanResults,
              actual.getOrElse(() => null),
            ),
          ),
        ]),
      );
    },
  );
  test(
    'when bluetooth state turned off during scan, ble scan stops',
    () async {
      final onEvent = DeviceState(
        bluetoothState: BluetoothState.on,
        locationServicesState: LocationServicesState.on,
      );

      final offEvent = DeviceState(
        bluetoothState: BluetoothState.off,
        locationServicesState: LocationServicesState.on,
      );

      // ignore: close_sinks
      final controller = StreamController<DeviceState>()..add(onEvent);

      final scanStream = Stream.fromIterable(_scanResults).doOnData((event) {
        // after first event, change bluetooth state
        controller.add(offEvent);
      });
      when(scanner.scan()).thenAnswer((_) => scanStream);

      expectLater(
        ScanStream.from(
          controller.stream,
          scanner,
        ),
        emitsInOrder([
          predicate(
            (Either<dynamic, List<EddystoneUid>> actual) => listEquals(
              _scanResults.getRange(0, 1).toList(),
              actual.getOrElse(() => null),
            ),
          ),
          left(DeviceState(
            bluetoothState: BluetoothState.off,
            locationServicesState: LocationServicesState.on,
          )),
        ]),
      );
    },
  );
}

const _scanResults = [
  EddystoneUid(
    frameType: 0,
    txPower: 0,
    namespace: "aaaaabbbbbcccccddddd",
    instance: "aaaaaabbbbbb",
  ),
  EddystoneUid(
    frameType: 0,
    txPower: 0,
    namespace: "bbbbbcccccdddddeeeee",
    instance: "bbbbbbcccccc",
  ),
];

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
        Stream.value(BluetoothState.on),
        Stream.fromIterable(states),
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
        Stream.fromIterable(states),
        Stream.value(LocationServicesState.on),
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

      expectLater(
        ScanStream.from(
          Stream.fromIterable([BluetoothState.off, BluetoothState.on]),
          Stream.value(LocationServicesState.on),
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
      // ignore: close_sinks
      final controller = StreamController<BluetoothState>()
        ..add(BluetoothState.on);

      final scanStream = Stream.fromIterable(_scanResults).doOnData((event) {
        // after first event, change bluetooth state
        controller.add(BluetoothState.off);
      });
      when(scanner.scan()).thenAnswer((_) => scanStream);

      expectLater(
        ScanStream.from(
          controller.stream,
          Stream.value(LocationServicesState.on),
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

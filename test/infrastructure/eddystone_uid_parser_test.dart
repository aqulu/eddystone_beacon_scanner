import 'dart:typed_data';

import 'package:eddystone_beacon_scanner/infrastructure/eddystone_uid_parser.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_ble_lib/flutter_ble_lib.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'when serviceUuids not present or empty parsing results in FormatException',
    () {
      final dataWithServiceUuidsNull = AdvertisementDataMock(
        serviceUuids: null,
        serviceData: {},
      );

      final dataWithEmptyServiceUuids = AdvertisementDataMock(
        serviceUuids: [],
        serviceData: {},
      );

      expect(
        () => dataWithServiceUuidsNull.toEddystoneUid(),
        throwsA(isInstanceOf<FormatException>()),
      );

      expect(
        () => dataWithEmptyServiceUuids.toEddystoneUid(),
        throwsA(isInstanceOf<FormatException>()),
      );
    },
  );

  test(
    'when serviceData key does not match any serviceUuid parsing results'
    ' in FormatException',
    () {
      final advertisementData = AdvertisementDataMock(
        serviceUuids: ['2'],
        serviceData: {'1': Uint8List.fromList(_examplePayload)},
      );

      expect(
        () => advertisementData.toEddystoneUid(),
        throwsA(isInstanceOf<FormatException>()),
      );
    },
  );

  test(
    'when frame does not match Eddystone-Uid length parsing results '
    'in FormatException',
    () {
      final dataWithTooLargeFrameLength = AdvertisementDataMock(
        serviceUuids: ['1'],
        serviceData: {
          '1': Uint8List.fromList(
            List.from(_examplePayload)..add(0),
          )
        },
      );

      final dataWithInsufficientFrameLength = AdvertisementDataMock(
        serviceUuids: ['1'],
        serviceData: {
          '1': Uint8List.fromList(
            List.from(_examplePayload)..removeLast(),
          )
        },
      );

      expect(
        () => dataWithInsufficientFrameLength.toEddystoneUid(),
        throwsA(isInstanceOf<FormatException>()),
      );

      expect(
        () => dataWithTooLargeFrameLength.toEddystoneUid(),
        throwsA(isInstanceOf<FormatException>()),
      );
    },
  );

  test(
    'single digit numbers are expanded to 2 digit strings',
    () {
      final advertisementData = AdvertisementDataMock(
        serviceUuids: ['1'],
        serviceData: {'1': Uint8List.fromList(_examplePayload)},
      );
      final eddystoneUid = advertisementData.toEddystoneUid();

      expect(eddystoneUid.namespace, '10000000000000000000');
      expect(eddystoneUid.instance, '9603ffffffff');
    },
  );

  test(
    'when frame does not contain reserved bytes parsing still succeeds',
    () {
      final advertisementData = AdvertisementDataMock(
        serviceUuids: ['1'],
        serviceData: {
          '1': Uint8List.fromList(_examplePayload.getRange(0, 18).toList())
        },
      );
      final eddystoneUid = advertisementData.toEddystoneUid();

      expect(eddystoneUid.namespace, '10000000000000000000');
      expect(eddystoneUid.instance, '9603ffffffff');
    },
  );
}

const _examplePayload = [
  0,
  235,
  16,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  150,
  3,
  255,
  255,
  255,
  255,
  0,
  0,
];

class AdvertisementDataMock implements AdvertisementData {
  AdvertisementDataMock({
    @required this.serviceUuids,
    @required this.serviceData,
  });

  @override
  List<String> serviceUuids;

  @override
  Map<String, Uint8List> serviceData;

  @override
  String localName = "";

  @override
  Uint8List manufacturerData = Uint8List(0);

  @override
  List<String> solicitedServiceUuids = [];

  @override
  int txPowerLevel = 0;
}

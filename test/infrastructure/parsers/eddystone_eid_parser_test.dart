import 'dart:typed_data';

import 'package:eddystone_beacon_scanner/infrastructure/parsers/eddystone_eid_parser.dart';
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
        () => dataWithServiceUuidsNull.toEddystoneEid(),
        throwsA(isInstanceOf<FormatException>()),
      );

      expect(
        () => dataWithEmptyServiceUuids.toEddystoneEid(),
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
        () => advertisementData.toEddystoneEid(),
        throwsA(isInstanceOf<FormatException>()),
      );
    },
  );

  test(
    'when frame does not match Eddystone-Eid length parsing results '
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
        () => dataWithInsufficientFrameLength.toEddystoneEid(),
        throwsA(isInstanceOf<FormatException>()),
      );

      expect(
        () => dataWithTooLargeFrameLength.toEddystoneEid(),
        throwsA(isInstanceOf<FormatException>()),
      );
    },
  );

  test(
    'when frameType is other than 0x30 results in FormatException',
    () {
      final data = AdvertisementDataMock(
        serviceUuids: ['1'],
        serviceData: {
          '1': Uint8List.fromList(
            List.from(_examplePayload)..replaceRange(0, 1, [1]),
          )
        },
      );

      expect(
        () => data.toEddystoneEid(),
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
      final eddystoneEid = advertisementData.toEddystoneEid();

      expect(eddystoneEid.eid, '1000000000000000');
    },
  );
}

const _examplePayload = [
  48,
  235,
  16,
  0,
  0,
  0,
  0,
  0,
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

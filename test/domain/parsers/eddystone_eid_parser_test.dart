import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:eddystone_beacon_scanner/domain/eddystone.dart';
import 'package:eddystone_beacon_scanner/domain/parsers/eddystone_eid_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'when frame does not match Eddystone-Eid length parsing results '
    'in FormatException',
    () {
      final dataWithTooLargeFrameLength = Uint8List.fromList(
        List.from(_examplePayload)..add(0),
      );

      final dataWithInsufficientFrameLength = Uint8List.fromList(
        List.from(_examplePayload)..removeLast(),
      );

      expect(
        dataWithInsufficientFrameLength.toEddystoneEid(),
        predicate((Either<FormatException, EddystoneEid> e) => e.isLeft()),
      );

      expect(
        dataWithTooLargeFrameLength.toEddystoneEid(),
        predicate((Either<FormatException, EddystoneEid> e) => e.isLeft()),
      );
    },
  );

  test(
    'when frameType is other than 0x30 results in FormatException',
    () {
      final payload = Uint8List.fromList(
        List.from(_examplePayload)..replaceRange(0, 1, [1]),
      );

      expect(
        payload.toEddystoneEid(),
        predicate((Either<FormatException, EddystoneEid> e) => e.isLeft()),
      );
    },
  );

  test(
    'single digit numbers are expanded to 2 digit strings',
    () {
      final payload = Uint8List.fromList(_examplePayload);
      final eddystoneEid = payload.toEddystoneEid();

      expect(eddystoneEid.map((r) => r.eid), right('1000000000000000'));
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

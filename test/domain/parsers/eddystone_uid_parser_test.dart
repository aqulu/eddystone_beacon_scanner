import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:eddystone_beacon_scanner/domain/eddystone.dart';
import 'package:eddystone_beacon_scanner/domain/parsers/eddystone_uid_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'when frame does not match Eddystone-Uid length parsing results '
    'in FormatException',
    () {
      final dataWithTooLargeFrameLength = Uint8List.fromList(
        List.from(_examplePayload)..add(0),
      );

      final dataWithInsufficientFrameLength = Uint8List.fromList(
        List.from(_examplePayload)..removeLast(),
      );

      expect(
        dataWithInsufficientFrameLength.toEddystoneUid(),
        predicate((Either<FormatException, EddystoneUid> e) => e.isLeft()),
      );

      expect(
        dataWithTooLargeFrameLength.toEddystoneUid(),
        predicate((Either<FormatException, EddystoneUid> e) => e.isLeft()),
      );
    },
  );

  test(
    'when frameType is other than 0x00 results in FormatException',
    () {
      final data = Uint8List.fromList(
        List.from(_examplePayload)..replaceRange(0, 1, [1]),
      );

      expect(
        data.toEddystoneUid(),
        predicate((Either<FormatException, EddystoneUid> e) => e.isLeft()),
      );
    },
  );

  test(
    'single digit numbers are expanded to 2 digit strings',
    () {
      final payload = Uint8List.fromList(_examplePayload);
      final eddystoneUid = payload.toEddystoneUid();

      expect(
        eddystoneUid.map((r) => r.namespace),
        right('10000000000000000000'),
      );
      expect(eddystoneUid.map((r) => r.instance), right('9603ffffffff'));
    },
  );

  test(
    'when frame does not contain reserved bytes parsing still succeeds',
    () {
      final payload = Uint8List.fromList(
        _examplePayload.getRange(0, 18).toList(),
      );
      final eddystoneUid = payload.toEddystoneUid();

      expect(
        eddystoneUid.map((r) => r.namespace),
        right('10000000000000000000'),
      );
      expect(eddystoneUid.map((r) => r.instance), right('9603ffffffff'));
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

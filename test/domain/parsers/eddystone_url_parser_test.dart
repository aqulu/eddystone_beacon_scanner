import 'dart:typed_data';

import 'package:eddystone_beacon_scanner/domain/parsers/eddystone_url_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'when frame does not match Eddystone-Url length parsing results '
    'in FormatException',
    () {
      final dataWithTooLargeFrameLength = Uint8List.fromList(
        List.from(_hn)..add(65),
      );

      final dataWithInsufficientFrameLength = Uint8List.fromList(
        _ddg.getRange(0, 3).toList(),
      );

      expect(
        () => dataWithInsufficientFrameLength.toEddystoneUrl(),
        throwsA(isInstanceOf<FormatException>()),
      );

      expect(
        () => dataWithTooLargeFrameLength.toEddystoneUrl(),
        throwsA(isInstanceOf<FormatException>()),
      );
    },
  );

  test(
    'when encountering unspecified / reserved special characters ignores them',
    () {
      final insertionIndex = _ddg.length - 2;
      // range 1
      for (int i = 0x0e; i <= 0x20; i++) {
        final data = Uint8List.fromList(
          List.from(_ddg)..insert(insertionIndex, i),
        );
        expect(data.toEddystoneUrl().url, "https://ddg.gg/");
      }

      // range 2
      for (int i = 0x7F; i <= 0xFF; i++) {
        final data = Uint8List.fromList(
          List.from(_ddg)..insert(insertionIndex, i),
        );
        expect(data.toEddystoneUrl().url, "https://ddg.gg/");
      }
    },
  );

  test(
    'when frameType is other than 0x10 results in FormatException',
    () {
      final payload = Uint8List.fromList(
        List.from(_ddg)..replaceRange(0, 1, [1]),
      );

      expect(
        () => payload.toEddystoneUrl(),
        throwsA(isInstanceOf<FormatException>()),
      );
    },
  );

  test('url scheme prefix resolving', () {
    final httpWww = Uint8List.fromList(
      List.from(_ddg)..replaceRange(2, 3, [0]),
    );

    final httpsWww = Uint8List.fromList(
      List.from(_ddg)..replaceRange(2, 3, [1]),
    );

    final http = Uint8List.fromList(
      List.from(_ddg)..replaceRange(2, 3, [2]),
    );

    final https = Uint8List.fromList(
      List.from(_ddg)..replaceRange(2, 3, [3]),
    );

    expect(httpWww.toEddystoneUrl().url, 'http://www.ddg.gg/');
    expect(httpsWww.toEddystoneUrl().url, 'https://www.ddg.gg/');
    expect(http.toEddystoneUrl().url, 'http://ddg.gg/');
    expect(https.toEddystoneUrl().url, 'https://ddg.gg/');
  });

  test(
    'when encountering unknown url scheme prefix results in FormatException',
    () {
      final payload = Uint8List.fromList(
        List.from(_ddg)..replaceRange(2, 3, [4]),
      );

      expect(
        () => payload.toEddystoneUrl(),
        throwsA(isInstanceOf<FormatException>()),
      );
    },
  );

  test('decode max length frame', () {
    expect(
      Uint8List.fromList(_hn).toEddystoneUrl().url,
      "https://news.ycombinator.com",
    );
  });
}

const _ddg = [
  16,
  235,
  3,
  100,
  100,
  103,
  46,
  103,
  103,
  47,
];

const _hn = [
  16,
  235,
  3,
  110,
  101,
  119,
  115,
  46,
  121,
  99,
  111,
  109,
  98,
  105,
  110,
  97,
  116,
  111,
  114,
  7,
];

import 'package:eddystone_beacon_scanner/core/timed_cache_transformer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'when shouldPreventDuplicates is on, duplicate check works with overridden '
    'equals function',
    () async {
      final stream = Stream.fromIterable([
        _Data(1, 1),
        _Data(2, 1),
        _Data(1, 2),
      ]);
      expectLater(
        stream.cacheFor(Duration(seconds: 4), shouldPreventDuplicates: true),
        emitsInOrder([
          _listEqualsPredicate([_Data(1, 1)]),
          _listEqualsPredicate([_Data(1, 1), _Data(2, 1)]),
          _listEqualsPredicate([_Data(2, 1), _Data(1, 2)]),
        ]),
      );
    },
  );

  test(
    'when shouldPreventDuplicates is false, results contain duplicate values',
    () async {
      final stream = Stream.fromIterable([1, 2, 1]);

      expectLater(
        stream.cacheFor(Duration(seconds: 4), shouldPreventDuplicates: false),
        emitsInOrder([
          _listEqualsPredicate([1]),
          _listEqualsPredicate([1, 2]),
          _listEqualsPredicate([1, 2, 1]),
        ]),
      );
    },
  );
}

Matcher _listEqualsPredicate(List<dynamic> list) =>
    predicate((actual) => listEquals(actual, list));

@immutable
class _Data {
  final int id;
  final int sequence;

  const _Data(this.id, this.sequence);

  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(other) =>
      identical(this, other) || other is _Data && id == other.id;
}

import 'dart:async';

import 'package:eddystone_beacon_scanner/infrastructure/ble_manager_safe_scan.dart';
import 'package:flutter_ble_lib/flutter_ble_lib.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class BleManagerMock extends Mock implements BleManager {}

class ScanResultMock extends Mock implements ScanResult {}

class BleErrorMock extends Mock implements BleError {}

void main() {
  final bleManager = BleManagerMock();

  test('when stream is done transformer emits done', () async {
    when(bleManager.stopPeripheralScan()).thenAnswer((_) => Future.value());

    final stream = Stream<ScanResult>.empty()
        .transform(BleSafeScanTransformer(bleManager));

    await expectLater(stream, emitsDone);
    verify(bleManager.stopPeripheralScan());
  });

  test('when subscription is cancelled, scan stops', () async {
    when(bleManager.stopPeripheralScan()).thenAnswer((_) => Future.value());

    final stream =
        Stream<ScanResult>.fromIterable(List.filled(3, ScanResultMock()))
            .transform(BleSafeScanTransformer(bleManager));

    // force subscription to finish before all elements have been emitted
    await stream.take(2).drain();
    verify(bleManager.stopPeripheralScan());
  });

  test(
    'when stream throws error transformer waits for stopPeripheralScan to complete and emits done after',
    () async {
      final completer = Completer.sync();
      when(bleManager.stopPeripheralScan()).thenAnswer(
        (_) => Future.delayed(Duration(milliseconds: 200), completer.complete),
      );

      final stream = Stream<ScanResult>.fromFutures([
        Future.value(ScanResultMock()),
        Future.error(BleErrorMock()),
        // additional events for stream not to automatically emit done
        Future.value(ScanResultMock()),
        Future.value(ScanResultMock()),
      ]).transform(BleSafeScanTransformer(bleManager));

      await expectLater(stream.skip(1), emitsDone);
      expect(completer.isCompleted, true);
      verify(bleManager.stopPeripheralScan());
    },
  );
}

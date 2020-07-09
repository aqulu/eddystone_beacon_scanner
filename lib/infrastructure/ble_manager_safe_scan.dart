import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_ble_lib/flutter_ble_lib.dart';

extension BleManagerSafeScan on BleManager {
  Stream<ScanResult> scan({
    int scanMode = ScanMode.balanced,
    bool allowDuplicates = true,
  }) =>
      startPeripheralScan(scanMode: scanMode, allowDuplicates: allowDuplicates)
          .transform(BleSafeScanTransformer(this));
}

///
/// when stopping a [BleManager.startPeripheralScan] using [BleManager.stopPeripheralScan]
/// and the stream's subscriber does not consume the done event,
/// the next time [BleManager.startPeripheralScan] is invoked the not-consumed done event will be emitted
///
/// To ensure this stream is being listened to until a done event has been emitted,
/// [_BleScanStopTransformer]
/// - terminate if bluetooth scan terminates early (if an error occurred)
/// - invoke [BleManager.stopPeripheralScan] when it's subscription has been cancelled and wait for it's completion
///
@visibleForTesting
class BleSafeScanTransformer
    extends StreamTransformerBase<ScanResult, ScanResult> {
  final BleManager _bleManager;

  const BleSafeScanTransformer(this._bleManager);

  @override
  Stream<ScanResult> bind(Stream<ScanResult> stream) {
    StreamSubscription<ScanResult> subscription;
    StreamController<ScanResult> controller;

    controller = StreamController<ScanResult>(
      sync: true,
      onListen: () {
        subscription = stream.listen(
          controller.add,
          onError: (error) {
            debugPrint("BleScanner encountered error: $error");
            controller.close();
          },
          onDone: controller.close,
          cancelOnError: true,
        );
      },
      onPause: () {
        subscription?.pause();
      },
      onResume: () {
        subscription?.resume();
      },
      onCancel: () async => _bleManager.stopPeripheralScan().then((_) {
        subscription.cancel();
      }),
    );

    return controller.stream;
  }
}

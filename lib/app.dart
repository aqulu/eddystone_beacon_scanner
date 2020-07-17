import 'package:dartz/dartz.dart';
import 'package:eddystone_beacon_scanner/domain/device_state.dart';
import 'package:eddystone_beacon_scanner/domain/scan_result.dart';
import 'package:eddystone_beacon_scanner/domain/scan_stream.dart';
import 'package:eddystone_beacon_scanner/infrastructure/bluetooth_state_stream.dart';
import 'package:eddystone_beacon_scanner/infrastructure/eddystone_scanner.dart';
import 'package:eddystone_beacon_scanner/infrastructure/location_services_state_stream.dart';
import 'package:eddystone_beacon_scanner/ui/loading_screen.dart';
import 'package:eddystone_beacon_scanner/ui/scan_screen.dart';
import 'package:eddystone_beacon_scanner/ui/setup_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ble_lib/flutter_ble_lib.dart' show BleManager;
import 'package:provider/provider.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MultiProvider(
        providers: [
          Provider(
            create: (_) => BleManager()..createClient(),
            dispose: (_, BleManager bleManager) {
              bleManager.destroyClient();
            },
          ),
          StreamProvider<Either<DeviceState, List<ScanResult>>>(
            create: (context) {
              final BleManager bleManager = Provider.of(context, listen: false);
              return ScanStream(
                BluetoothStateStream(bleManager),
                LocationServicesStateStream.forPlatform(),
                EddystoneScanner(bleManager),
              );
            },
          ),
        ],
        child: MaterialApp(
          title: 'Eddystone Beacon Scanner',
          theme: ThemeData(
            brightness: Brightness.dark,
            primarySwatch: Colors.red,
            accentColor: Colors.white,
            visualDensity: VisualDensity.adaptivePlatformDensity,
            cardTheme: CardTheme(shape: Border()),
          ),
          home: _ScreenSwitcher(),
        ),
      );
}

/// switches between [ScanScreen] and [SetupScreen] depending on
/// state emitted from ScanStream
class _ScreenSwitcher extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Selector<Either<DeviceState, List<ScanResult>>, Option<bool>>(
        selector: (_, either) => optionOf(either?.isRight()),
        builder: (_, Option<bool> canScanOption, __) => canScanOption.fold(
          () => LoadingScreen(),
          (canScan) => canScan ? ScanScreen() : SetupScreen(),
        ),
      );
}

import 'package:dartz/dartz.dart';
import 'package:eddystone_beacon_scanner/domain/device_state.dart';
import 'package:eddystone_beacon_scanner/domain/eddystone_uid.dart';
import 'package:eddystone_beacon_scanner/domain/scan_stream.dart';
import 'package:eddystone_beacon_scanner/infrastructure/bluetooth_state_stream.dart';
import 'package:eddystone_beacon_scanner/infrastructure/eddystone_scanner.dart';
import 'package:eddystone_beacon_scanner/infrastructure/location_services_state_stream.dart';
import 'package:eddystone_beacon_scanner/ui/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ble_lib/flutter_ble_lib.dart' as ble;
import 'package:provider/provider.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MultiProvider(
        providers: [
          Provider(
            create: (_) => ble.BleManager()..createClient(),
            dispose: (_, ble.BleManager bleManager) {
              bleManager.destroyClient();
            },
          ),
          StreamProvider<Either<DeviceState, List<EddystoneUid>>>(
            create: (context) {
              final ble.BleManager bleManager = Provider.of(
                context,
                listen: false,
              );
              return ScanStream(
                BluetoothStateStream(bleManager),
                LocationServicesStateStream.forPlatform(),
                EddystoneScanner(bleManager),
              );
            },
            initialData: left(
              DeviceState(
                bluetoothState: BluetoothState.unknown,
                locationServicesState:
                    LocationServicesState.permissionUndetermined,
              ),
            ),
          ),
        ],
        child: MaterialApp(
          title: 'Eddystone Beacon Scanner',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          home: Home(),
        ),
      );
}

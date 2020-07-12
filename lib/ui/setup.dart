import 'package:eddystone_beacon_scanner/domain/device_state.dart';
import 'package:eddystone_beacon_scanner/domain/scan_stream.dart';
import 'package:eddystone_beacon_scanner/infrastructure/bluetooth_state_stream.dart';
import 'package:eddystone_beacon_scanner/infrastructure/location_services_state_stream.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Setup extends StatelessWidget {
  @override
  Widget build(BuildContext context) => SafeArea(
        child: Scaffold(
          body: MultiProvider(
            providers: [
              StreamProvider(
                create: (context) => DeviceStateStream.from(
                  BluetoothStateStream(Provider.of(context, listen: false)),
                  LocationServicesStateStream.forPlatform(),
                ),
                initialData: DeviceState(
                  bluetoothState: BluetoothState.unknown,
                  locationServicesState:
                      LocationServicesState.permissionUndetermined,
                ),
              ),
            ],
            child: Center(
              child: SingleChildScrollView(
                child: _Setup(),
              ),
            ),
          ),
        ),
      );
}

class _Setup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final DeviceState deviceState = Provider.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (deviceState.canPerformBleScan)
          FlatButton(
            child: Icon(Icons.arrow_forward),
            onPressed: () {
              // navigate to scan screen
            },
          ),
        if (deviceState.bluetoothState == BluetoothState.off)
          FlatButton.icon(
            icon: Icon(Icons.bluetooth_disabled),
            label: Text('Please turn bluetooth on'),
            onPressed: () {
              // TODO open bluetooth settings
            },
          ),
        if (deviceState.bluetoothState == BluetoothState.noPermissions) ...[
          Text(
            'This app requires Bluetooth permissions to scan for '
            'nearby BLE devices',
          ),
          FlatButton.icon(
            icon: Icon(Icons.settings_bluetooth),
            label: Text('Open app settings'),
            onPressed: () {
              // TODO open app settings
            },
          ),
        ],
        if ([
          LocationServicesState.permissionUndetermined,
          LocationServicesState.permissionDenied,
        ].contains(deviceState.locationServicesState)) ...[
          Text(
            'BLE scanning requires location service permissions',
          ),
          FlatButton.icon(
            icon: Icon(Icons.not_listed_location),
            label: Text('Open app settings'),
            onPressed: () {
              if (deviceState.locationServicesState ==
                  LocationServicesState.permissionPermanentlyDenied) {
                // TODO open app settings
              } else {
                // TODO request permission
              }
            },
          ),
        ],
        if (deviceState.locationServicesState == LocationServicesState.off)
          FlatButton.icon(
            icon: Icon(Icons.location_off),
            label: Text('Please turn location services on'),
            onPressed: () {
              // TODO open location service settings
            },
          ),
      ],
    );
  }
}

import 'package:dartz/dartz.dart' show Either;
import 'package:eddystone_beacon_scanner/domain/device_state.dart';
import 'package:eddystone_beacon_scanner/domain/eddystone_uid.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SetupScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => SafeArea(
        child: Scaffold(
          body: ProxyProvider<Either<DeviceState, List<EddystoneUid>>,
              DeviceState>(
            update: (_, either, __) => either.fold(
              (deviceState) => deviceState,
              (_) => null,
            ),
            // avoid rebuilding whole screen on scan result update
            child: _Setup(),
          ),
        ),
      );
}

class _Setup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final DeviceState deviceState = Provider.of(context);

    if (deviceState == null) return Container();

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

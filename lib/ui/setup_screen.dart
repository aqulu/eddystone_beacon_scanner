import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:dartz/dartz.dart' show Either;
import 'package:eddystone_beacon_scanner/domain/device_state.dart';
import 'package:eddystone_beacon_scanner/domain/scan_result.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class SetupScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => SafeArea(
        child: Scaffold(
          body:
              ProxyProvider<Either<DeviceState, List<ScanResult>>, DeviceState>(
            update: (_, either, __) => either.fold(
              (deviceState) => deviceState,
              (_) => null,
            ),
            // avoid rebuilding whole screen on scan result update
            child: Center(child: _Setup()),
          ),
        ),
      );
}

class _Setup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final DeviceState deviceState = Provider.of(context);

    return (deviceState == null || deviceState.canPerformBleScan)
        ? Container()
        : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (deviceState.bluetoothState == BluetoothState.off)
                RaisedButton.icon(
                  icon: Icon(Icons.bluetooth_disabled),
                  label: Text('Please turn Bluetooth on'),
                  onPressed: AppSettings.openBluetoothSettings,
                ),
              if (deviceState.bluetoothState ==
                  BluetoothState.noPermissions) ...[
                Text(
                  'This app requires Bluetooth permissions to scan for '
                  'nearby BLE devices',
                ),
                RaisedButton.icon(
                  icon: Icon(Icons.settings_bluetooth),
                  label: Text('Open app settings'),
                  onPressed: AppSettings.openBluetoothSettings,
                ),
              ],
              if ([
                LocationServicesState.permissionUndetermined,
                LocationServicesState.permissionDenied,
              ].contains(deviceState.locationServicesState)) ...[
                Text(
                  'BLE scanning requires location service permissions',
                ),
                RaisedButton.icon(
                  icon: Icon(Icons.not_listed_location),
                  label: Text('Grant permissions'),
                  onPressed: (!Platform.isIOS)
                      ? Permission.locationWhenInUse.request
                      : null,
                ),
              ],
              if ([
                LocationServicesState.permissionPermanentlyDenied,
              ].contains(deviceState.locationServicesState)) ...[
                Text(
                  'BLE scanning requires location service permissions',
                ),
                RaisedButton.icon(
                  icon: Icon(Icons.not_listed_location),
                  label: Text('Open app settings'),
                  onPressed: AppSettings.openAppSettings,
                ),
              ],
              if (deviceState.locationServicesState ==
                  LocationServicesState.off)
                RaisedButton.icon(
                  icon: Icon(Icons.location_off),
                  label: Text('Please turn location services on'),
                  onPressed: AppSettings.openLocationSettings,
                ),
            ],
          );
  }
}

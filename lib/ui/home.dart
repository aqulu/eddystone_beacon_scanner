import 'package:dartz/dartz.dart' as dartz;
import 'package:eddystone_beacon_scanner/domain/device_state.dart';
import 'package:eddystone_beacon_scanner/domain/eddystone_uid.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) => SafeArea(
        child: Scaffold(
          body: MultiProvider(
            providers: [
              /// Proxy Either to List<EddystoneUid> for _Scan widget
              ProxyProvider<dartz.Either<DeviceState, List<EddystoneUid>>,
                  List<EddystoneUid>>(
                update: (_, either, __) => either.getOrElse(() => []),
                updateShouldNotify: (previous, current) {
                  return !listEquals(previous, current);
                },
              ),

              /// Proxy Either to DeviceState for _Scan widget
              ProxyProvider<dartz.Either<DeviceState, List<EddystoneUid>>,
                  DeviceState>(
                update: (_, either, __) => either.fold(
                  (deviceState) => deviceState,
                  (_) => null,
                ),
              ),
            ],
            // avoid rebuilding whole screen on scan result update
            child:
                Selector<dartz.Either<DeviceState, List<EddystoneUid>>, bool>(
              selector: (_, either) => either.isRight(),
              builder: (_, bool canScan, __) => canScan ? _Scan() : _Setup(),
            ),
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

class _Scan extends StatefulWidget {
  @override
  __ScanState createState() => __ScanState();
}

class __ScanState extends State<_Scan> {
  @override
  Widget build(BuildContext context) {
    final List<EddystoneUid> eddystoneUids = Provider.of(context);
    return CustomScrollView(
      slivers: [
        SliverGrid(
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 2.0,
            mainAxisSpacing: 0,
            crossAxisSpacing: 0,
            childAspectRatio: 1.0,
          ),
          delegate: SliverChildBuilderDelegate(
            (_, int index) {
              final element = eddystoneUids[index];
              return Card(
                child: Column(
                  children: [
                    Text(element.instance),
                    Text(element.namespace),
                  ],
                ),
              );
            },
            childCount: eddystoneUids.length,
          ),
        ),
      ],
    );
  }
}

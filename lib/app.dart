import 'package:eddystone_beacon_scanner/ui/setup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ble_lib/flutter_ble_lib.dart';
import 'package:provider/provider.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Provider(
        create: (_) => BleManager()..createClient(),
        dispose: (_, BleManager bleManager) {
          bleManager.destroyClient();
        },
        child: MaterialApp(
          title: 'Eddystone Beacon Scanner',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          home: Setup(),
        ),
      );
}

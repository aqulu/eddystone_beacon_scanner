import 'package:dartz/dartz.dart' show Either;
import 'package:eddystone_beacon_scanner/domain/device_state.dart';
import 'package:eddystone_beacon_scanner/domain/eddystone.dart';
import 'package:eddystone_beacon_scanner/ui/widgets/scan_result_card.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ScanScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => SafeArea(
        child: Scaffold(
          body: ProxyProvider<Either<DeviceState, List<EddystoneUid>>,
              List<EddystoneUid>>(
            update: (_, either, __) => either.getOrElse(() => []),
            updateShouldNotify: (previous, current) {
              return !listEquals(previous, current);
            },
            child: _ScanResults(),
          ),
        ),
      );
}

class _ScanResults extends StatefulWidget {
  @override
  _ScanResultsState createState() => _ScanResultsState();
}

class _ScanResultsState extends State<_ScanResults> {
  @override
  Widget build(BuildContext context) {
    final List<EddystoneUid> eddystoneUids = Provider.of(context);

    return CustomScrollView(
      slivers: [
        SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 0,
            crossAxisSpacing: 0,
            childAspectRatio: 1.0,
          ),
          delegate: SliverChildBuilderDelegate(
            (_, int index) => ScanResultCard(eddystoneUids[index]),
            childCount: eddystoneUids.length,
          ),
        ),
      ],
    );
  }
}

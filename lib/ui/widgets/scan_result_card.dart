import 'package:eddystone_beacon_scanner/domain/eddystone.dart';
import 'package:eddystone_beacon_scanner/domain/scan_result.dart';
import 'package:flutter/material.dart';

///
/// Displays a single [EddystoneUid] in a [Card] layout
///
class ScanResultCard extends StatelessWidget {
  final ScanResult _scanResult;

  const ScanResultCard(this._scanResult);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                "rssi: ${_scanResult.rssi}",
                style: textTheme.caption,
              ),
            ),
            ..._scanResult.payload.when(
              eddystoneUid: (uid) => _buildUidContent(uid, textTheme),
              eddystoneEid: _buildEidContent,
              eddystoneUrl: _buildUrlContent,
              fallback: (_) => [],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildUidContent(
    EddystoneUid uid,
    TextTheme textTheme,
  ) =>
      [
        Text(uid.namespace),
        Text(
          uid.instance,
          style: textTheme.bodyText1,
        ),
        Text("${uid.txPower} dBm"),
      ];

  List<Widget> _buildEidContent(EddystoneEid eid) => [
        Text(eid.eid),
        Text("${eid.txPower} dBm"),
      ];

  List<Widget> _buildUrlContent(EddystoneUrl url) => [
        Text(url.url),
        Text("${url.txPower} dBm"),
      ];
}

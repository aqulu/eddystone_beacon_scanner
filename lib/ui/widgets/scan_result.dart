import 'package:eddystone_beacon_scanner/domain/eddystone_uid.dart';
import 'package:flutter/material.dart';

///
/// Displays a single [EddystoneUid] in a [Card] layout
///
class ScanResultCard extends StatelessWidget {
  final EddystoneUid _eddystoneUid;

  const ScanResultCard(this._eddystoneUid);

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
            Text(_eddystoneUid.namespace),
            Text(
              _eddystoneUid.instance,
              style: textTheme.bodyText1,
            ),
          ],
        ),
      ),
    );
  }
}

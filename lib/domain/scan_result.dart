import 'package:eddystone_beacon_scanner/domain/eddystone.dart';
import 'package:flutter/foundation.dart';

@immutable
class ScanResult {
  /// received signal strength in dBm
  final int rssi;

  /// the eddystone payload
  final EddystonePayload payload;

  const ScanResult({
    @required this.rssi,
    @required this.payload,
  });

  @override
  int get hashCode => payload.hashCode;

  @override
  bool operator ==(other) =>
      identical(this, other) || other is ScanResult && payload == other.payload;
}

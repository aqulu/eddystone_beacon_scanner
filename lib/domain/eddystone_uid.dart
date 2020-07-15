import 'package:flutter/foundation.dart';

///
/// holds radix16 string representations of the fields present in
/// Eddystone-UID frame broadcasts
///
/// format ref: https://github.com/google/eddystone/tree/master/eddystone-uid/
///
@immutable
class EddystoneUid {
  static const int frameLength = 18;
  static const int frameLengthWithReservedBytes = 20;

  /// always 0 (0x00)
  static const int frameType = 0x00;

  /// txPower in dBm at 0 meters
  final int txPower;

  /// namespace
  /// (10 byte; radix16 string length = 20)
  final String namespace;

  /// instance
  /// (6 byte; radix16 string length = 12)
  final String instance;

  const EddystoneUid({
    @required this.txPower,
    @required this.namespace,
    @required this.instance,
  })  : assert(namespace.length == 20),
        assert(instance.length == 12);

  @override
  int get hashCode => namespace.hashCode ^ instance.hashCode;

  @override
  bool operator ==(other) =>
      identical(this, other) ||
      other is EddystoneUid &&
          namespace == other.namespace &&
          instance == other.instance;

  @override
  String toString() => "EddystoneUid(\n"
      "\tinstance: $instance,\n"
      "\tnamespace: $namespace\n"
      ")";
}

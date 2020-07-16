import 'package:flutter/foundation.dart';

abstract class EddystonePayload {}

///
/// holds radix16 string representations of the fields present in
/// Eddystone-UID frame broadcasts
///
/// format ref: https://github.com/google/eddystone/tree/master/eddystone-uid/
///
@immutable
class EddystoneUid implements EddystonePayload {
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

///
/// holds radix16 string representations of the eid field present in
/// Eddystone-EID frame broadcasts
///
/// format ref: https://github.com/google/eddystone/tree/master/eddystone-eid/
///
class EddystoneEid implements EddystonePayload {
  static const int frameLength = 10;

  /// always 0x30
  static const int frameType = 0x30;

  /// txPower in dBm at 0 meters
  final int txPower;

  /// ephemeral identifier
  /// (8 byte; radix16 string length = 16)
  final String eid;

  const EddystoneEid({
    @required this.txPower,
    @required this.eid,
  }) : assert(eid.length == 16);

  @override
  int get hashCode => eid.hashCode;

  @override
  bool operator ==(other) =>
      identical(this, other) || other is EddystoneEid && eid == other.eid;

  @override
  String toString() => "EddystoneEid(eid: $eid)";
}

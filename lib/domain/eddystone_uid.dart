import 'package:flutter/foundation.dart';

///
/// holds radix16 string representations of the fields present in
/// Eddystone-UID frame broadcasts
///
/// format ref: https://github.com/google/eddystone/tree/master/eddystone-uid/
///
@immutable
class EddystoneUid {
  static const int frameLength = 20;

  /// always 0 (0x00)
  final int frameType;

  /// txPower in dBm at 0 meters
  final int txPower;

  /// namespace
  /// (10 byte; radix16 string length = 20)
  final String namespace;

  /// instance
  /// (6 byte; radix16 string length = 12)
  final String instance;

  const EddystoneUid({
    @required this.frameType,
    @required this.txPower,
    @required this.namespace,
    @required this.instance,
  })  : assert(frameType == 0),
        assert(namespace.length == 20),
        assert(instance.length == 12);
}

import 'dart:typed_data';

import 'package:eddystone_beacon_scanner/domain/parsers/eddystone_eid_parser.dart';
import 'package:eddystone_beacon_scanner/domain/parsers/eddystone_uid_parser.dart';
import 'package:eddystone_beacon_scanner/domain/parsers/eddystone_url_parser.dart';
import 'package:flutter/foundation.dart';

abstract class EddystonePayload {
  // hide constructor
  // ignore: unused_element
  const EddystonePayload._();

  ///
  /// parses an [Uint8List] to an [EddystonePayload]
  ///
  /// throws a [FormatException] if the advertised frame does not match any of the
  /// supported Eddystone formats
  /// or, if [suppressErrors] is true, returns [null] instead of throwing
  ///
  factory EddystonePayload.parse(
    Uint8List payload, {
    bool throwErrors = false,
  }) {
    final frameType = payload != null && payload.isNotEmpty ? payload[0] : null;

    final nullOrThrow = (FormatException formatException) =>
        (throwErrors) ? throw formatException : null;

    switch (frameType) {
      case EddystoneUid.frameType:
        return payload.toEddystoneUid().fold(nullOrThrow, (r) => r);
      case EddystoneEid.frameType:
        return payload.toEddystoneEid().fold(nullOrThrow, (r) => r);
      case EddystoneUrl.frameType:
        return payload.toEddystoneUrl().fold(nullOrThrow, (r) => r);
      default:
        return nullOrThrow(FormatException(
          "FrameType $frameType did not match any of the supported "
          "eddystone formats",
        ));
    }
  }
}

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

///
/// holds a url string present in Eddystone-URL frame broadcasts
///
/// format ref: https://github.com/google/eddystone/tree/master/eddystone-url/
///
class EddystoneUrl implements EddystonePayload {
  static const int minFrameLength = 4;
  static const int maxFrameLength = 20;

  /// always 0x10
  static const int frameType = 0x10;

  /// txPower in dBm at 0 meters
  final int txPower;

  /// url
  final String url;

  const EddystoneUrl({
    @required this.txPower,
    @required this.url,
  });

  @override
  int get hashCode => url.hashCode;

  @override
  bool operator ==(other) =>
      identical(this, other) || other is EddystoneUrl && url == other.url;

  @override
  String toString() => "EddystoneUrl(url: $url)";
}

extension When on EddystonePayload {
  /// mimic kotlin's `when` for sealed classes
  ///
  /// (only handles subclasses defined in lib/domain/eddystone.dart; other will fall back to [fallback])
  T when<T>({
    @required T Function(EddystoneUid) eddystoneUid,
    @required T Function(EddystoneEid) eddystoneEid,
    @required T Function(EddystoneUrl) eddystoneUrl,
    T Function(EddystonePayload) fallback,
  }) {
    if (this is EddystoneUid && eddystoneUid != null) return eddystoneUid(this);

    if (this is EddystoneEid && eddystoneEid != null) return eddystoneEid(this);

    if (this is EddystoneUrl && eddystoneUrl != null) return eddystoneUrl(this);

    return (fallback != null) ? fallback(this) : null;
  }
}

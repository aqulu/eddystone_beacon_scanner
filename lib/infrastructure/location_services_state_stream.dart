import 'dart:async';

import 'package:eddystone_beacon_scanner/domain/device_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationServicesStateStream extends StreamView<LocationServicesState> {
  const LocationServicesStateStream._(Stream<LocationServicesState> stream)
      : super(stream);

  /// ios devices do not need location services for BLE scanning;
  /// avoid invoking platform-interfaces that would require location permissions
  /// by emitting [LocationServicesState.notRequired]
  factory LocationServicesStateStream.ios() => LocationServicesStateStream._(
        Stream.value(LocationServicesState.notRequired),
      );

  factory LocationServicesStateStream.android({
    Duration interval = const Duration(seconds: 3),
  }) {
    final stream = Stream.periodic(interval).asyncMap(
      (_) => requestLocationServicesState(
        () => Permission.locationWhenInUse.status,
        () => Permission.locationWhenInUse.serviceStatus,
      ),
    );
    return LocationServicesStateStream._(stream);
  }
}

///
/// queries the current LocationServices permission status and serviceStatus and
/// maps the result to a [LocationServicesState] instance
///
@visibleForTesting
Future<LocationServicesState> requestLocationServicesState(
  PermissionStatusRequestBuilder permissionStatusRequestBuilder,
  ServiceStatusRequestBuilder serviceStatusRequestBuilder,
) async {
  final permission = await permissionStatusRequestBuilder();

  switch (permission) {
    case PermissionStatus.undetermined:
      return LocationServicesState.permissionUndetermined;
    case PermissionStatus.denied:
      return LocationServicesState.permissionDenied;
    case PermissionStatus.permanentlyDenied:
      return LocationServicesState.permissionPermanentlyDenied;
    case PermissionStatus.granted:
      return await serviceStatusRequestBuilder().then(
        (serviceStatus) => (serviceStatus == ServiceStatus.enabled)
            ? LocationServicesState.on
            : LocationServicesState.off,
      );
    case PermissionStatus.restricted:
    default:
      throw PlatformException(code: 'android_only');
  }
}

typedef PermissionStatusRequestBuilder = Future<PermissionStatus> Function();
typedef ServiceStatusRequestBuilder = Future<ServiceStatus> Function();

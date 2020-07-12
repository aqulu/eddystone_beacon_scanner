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

  factory LocationServicesStateStream.android(
    PermissionWithService locationWhenInUsePermission,
  ) {
    final stream = Stream.periodic(Duration(seconds: 3)).asyncMap(
      (_) => requestLocationServicesState(locationWhenInUsePermission),
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
  PermissionWithService locationWhenInUsePermission,
) async {
  final permission = await locationWhenInUsePermission.status;

  switch (permission) {
    case PermissionStatus.undetermined:
      return LocationServicesState.permissionUndetermined;
    case PermissionStatus.denied:
      return LocationServicesState.permissionDenied;
    case PermissionStatus.permanentlyDenied:
      return LocationServicesState.permissionPermanentlyDenied;
    case PermissionStatus.granted:
      return await locationWhenInUsePermission.serviceStatus.then(
        (serviceStatus) => (serviceStatus == ServiceStatus.enabled)
            ? LocationServicesState.on
            : LocationServicesState.off,
      );
    case PermissionStatus.restricted:
    default:
      throw PlatformException(code: 'android_only');
  }
}

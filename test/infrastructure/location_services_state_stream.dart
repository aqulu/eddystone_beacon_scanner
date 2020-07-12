import 'package:eddystone_beacon_scanner/domain/device_state.dart';
import 'package:eddystone_beacon_scanner/infrastructure/location_services_state_stream.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  test('when on ios stream returns notRequired state', () {
    final stream = LocationServicesStateStream.ios();
    expect(stream, emits(LocationServicesState.notRequired));
  });

  test(
    'when requesting service returns ios only value throws PlatformException',
    () async {
      expectLater(
        requestLocationServicesState(
          () => Future.value(PermissionStatus.restricted),
          () => Future.error(Exception('should not be called')),
        ),
        throwsA(isInstanceOf<PlatformException>()),
      );
    },
  );

  test(
    'when permission granted returns service status',
    () async {
      expect(
        await requestLocationServicesState(
          () => Future.value(PermissionStatus.granted),
          () => Future.value(ServiceStatus.enabled),
        ),
        LocationServicesState.on,
      );
    },
  );

  test(
    'when permission unknown, denied or permanently denied, status is reflected'
    ' in LocationServicesState',
    () async {
      expect(
        await requestLocationServicesState(
          () => Future.value(PermissionStatus.undetermined),
          () => Future.error(Exception('should not be called')),
        ),
        LocationServicesState.permissionUndetermined,
      );

      expect(
        await requestLocationServicesState(
          () => Future.value(PermissionStatus.denied),
          () => Future.error(Exception('should not be called')),
        ),
        LocationServicesState.permissionDenied,
      );

      expect(
        await requestLocationServicesState(
          () => Future.value(PermissionStatus.permanentlyDenied),
          () => Future.error(Exception('should not be called')),
        ),
        LocationServicesState.permissionPermanentlyDenied,
      );
    },
  );
}

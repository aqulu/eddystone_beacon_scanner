import 'package:eddystone_beacon_scanner/domain/device_state.dart';
import 'package:eddystone_beacon_scanner/infrastructure/location_services_state_stream.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionMock extends Mock implements PermissionWithService {}

void main() {
  test('when on ios stream returns notRequired state', () {
    final stream = LocationServicesStateStream.ios();
    expect(stream, emits(LocationServicesState.notRequired));
  });

  final permission = PermissionMock();

  test(
    'when requesting service returns ios only value throws PlatformException',
    () async {
      when(permission.status)
          .thenAnswer((_) => Future.value(PermissionStatus.restricted));

      expectLater(
        requestLocationServicesState(permission),
        throwsA(isInstanceOf<PlatformException>()),
      );
    },
    skip: 'cannot mock extension methods',
  );

  test(
    'when permission granted returns service status',
    () async {
      when(permission.status)
          .thenAnswer((_) => Future.value(PermissionStatus.granted));
      when(permission.serviceStatus)
          .thenAnswer((_) => Future.value(ServiceStatus.enabled));

      await expectLater(
        requestLocationServicesState(permission),
        LocationServicesState.on,
      );

      verify(permission.serviceStatus);
    },
    skip: 'cannot mock extension methods',
  );

  test(
    'when permission unknown, denied or permanently denied, status is reflected'
    ' in LocationServicesState',
    () async {
      when(permission.status)
          .thenAnswer((_) => Future.value(PermissionStatus.undetermined));
      await expectLater(
        requestLocationServicesState(permission),
        LocationServicesState.permissionUndetermined,
      );

      when(permission.status)
          .thenAnswer((_) => Future.value(PermissionStatus.denied));
      await expectLater(
        requestLocationServicesState(permission),
        LocationServicesState.permissionDenied,
      );

      when(permission.status)
          .thenAnswer((_) => Future.value(PermissionStatus.permanentlyDenied));
      await expectLater(
        requestLocationServicesState(permission),
        LocationServicesState.permissionPermanentlyDenied,
      );
    },
    skip: 'cannot mock extension methods',
  );
}

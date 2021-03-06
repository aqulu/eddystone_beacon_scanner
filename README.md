# eddystone_beacon_scanner

![build](https://github.com/aqulu/eddystone_beacon_scanner/workflows/build/badge.svg) ![lint](https://github.com/aqulu/eddystone_beacon_scanner/workflows/lint/badge.svg) ![test](https://github.com/aqulu/eddystone_beacon_scanner/workflows/test/badge.svg)

A Bluetooth Low Energy (BLE) beacon scanning utility for [Eddystone-Uid](https://github.com/google/eddystone/tree/master/eddystone-uid/), [Eddystone-Eid](https://github.com/google/eddystone/tree/master/eddystone-eid/) and [Eddystone-Url](https://github.com/google/eddystone/tree/master/eddystone-url/) compatible beacons.

Features a customized `ShapeBorder` class to render Widgets with a "pixelated" shape and/or border.

### setup

Install the pub dependencies by executing following command from the project's root directory.

```
flutter pub get
```

### running

Make sure a device connected to your computer, then run

```
flutter run
```

to start the app. Since the app's core feature relies on the device's bluetooth capabilities, running inside
an emulator may lead to crashes.

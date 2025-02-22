// Copyright 2019 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('dev.fluttercommunity.plus/package_info');
  final log = <MethodCall>[];

  channel.setMockMethodCallHandler((MethodCall methodCall) async {
    log.add(methodCall);
    switch (methodCall.method) {
      case 'getAll':
        return <String, dynamic>{
          'appName': 'package_info_example',
          'buildNumber': '1',
          'packageName': 'io.flutter.plugins.packageinfoexample',
          'version': '1.0',
          'installerStore': null,
        };
      default:
        assert(false);
        return null;
    }
  });

  tearDown(() {
    log.clear();
  });

  test('fromPlatform', () async {
    final info = await PackageInfo.fromPlatform();
    expect(info.appName, 'package_info_example');
    expect(info.buildNumber, '1');
    expect(info.packageName, 'io.flutter.plugins.packageinfoexample');
    expect(info.version, '1.0');
    expect(info.installerStore, null);
    expect(
      log,
      <Matcher>[
        isMethodCall('getAll', arguments: null),
      ],
    );
  }, onPlatform: {
    'linux':
        const Skip('PackageInfoPlus on Linux does not use platform channels'),
  });

  test('Mock initial values', () async {
    PackageInfo.setMockInitialValues(
      appName: 'mock_package_info_example',
      packageName: 'io.flutter.plugins.mockpackageinfoexample',
      version: '1.1',
      buildNumber: '2',
      buildSignature: 'deadbeef',
      installerStore: null,
    );
    final info = await PackageInfo.fromPlatform();
    expect(info.appName, 'mock_package_info_example');
    expect(info.buildNumber, '2');
    expect(info.packageName, 'io.flutter.plugins.mockpackageinfoexample');
    expect(info.version, '1.1');
    expect(info.buildSignature, 'deadbeef');
    expect(info.installerStore, null);
  });
}

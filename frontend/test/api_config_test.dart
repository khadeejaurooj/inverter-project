import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutterproject/core/network/api_config.dart';

void main() {
  test('the defaults are safe placeholders with the right shape', () {
    expect(ApiConfig.baseUrl, isNotEmpty);
    expect(ApiConfig.baseUrl.endsWith('/'), isFalse, reason: 'services append "/api/..."');
    expect(
      RegExp(r'^([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}$').hasMatch(ApiConfig.defaultInverterMac),
      isTrue,
    );
  });

  test('no server address or device MAC is hard-coded outside ApiConfig', () {
    final address = RegExp(r'https?://');
    final mac = RegExp(r'\b([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}\b');

    final offenders = <String>[];
    for (final entity in Directory('lib').listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      final normalized = entity.path.replaceAll('\\', '/');
      if (normalized.endsWith('core/network/api_config.dart')) continue;
      // The UI's example hint text is an obvious placeholder, not a real device.
      final text = entity.readAsStringSync().replaceAll('AA:BB:CC:DD:EE:FF', '');
      if (address.hasMatch(text) || mac.hasMatch(text)) offenders.add(normalized);
    }

    expect(
      offenders,
      isEmpty,
      reason: 'Put server addresses and device identifiers in ApiConfig (set with --dart-define), not in the code.',
    );
  });
}

import 'package:flutter/foundation.dart';

/// Base URL of the Ringlead backend (see ../../backend).
///
/// Override at build/run time with `--dart-define=API_BASE_URL=https://your-host/api`.
/// Without an override, points at localhost via whichever loopback address
/// each platform's emulator/simulator uses to reach the host machine.
class ApiConfig {
  ApiConfig._();

  static const _override = String.fromEnvironment('API_BASE_URL');

  static String get baseUrl {
    if (_override.isNotEmpty) return _override;
    if (defaultTargetPlatform == TargetPlatform.android) return 'http://10.0.2.2:5000/api';
    return 'http://localhost:5000/api';
  }
}

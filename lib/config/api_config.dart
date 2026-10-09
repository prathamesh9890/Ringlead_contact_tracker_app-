/// Base URL of the Ringlead backend (see ../../backend).
///
/// Defaults to the live backend on Render. To use a local backend instead,
/// override at build/run time, e.g. on the Android emulator:
/// `flutter run --dart-define=API_BASE_URL=http://10.0.2.2:5000/api`
class ApiConfig {
  ApiConfig._();

  static const _override = String.fromEnvironment('API_BASE_URL');
  static const _live = 'https://ringlead.onrender.com/api';

  static String get baseUrl => _override.isNotEmpty ? _override : _live;
}

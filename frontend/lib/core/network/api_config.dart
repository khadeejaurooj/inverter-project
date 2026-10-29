/// Where the app finds its backend, and which inverter the dashboard shows
/// until the user registers their own.
///
/// Both values are set when the app is built or run, so no server address or
/// device identifier is stored in the source code:
///
///   flutter run --dart-define=API_BASE_URL=http://10.0.2.2:24301 \
///               --dart-define=DEFAULT_INVERTER_MAC=AA:BB:CC:DD:EE:FF
///
/// Without these settings the app expects a backend on this computer
/// (see the `backend/` folder of the repository). From an Android emulator use
/// `http://10.0.2.2:<port>`; from a phone use the computer's network address.
class ApiConfig {
  /// Base address of the backend, without a trailing slash.
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:24301',
  );

  /// MAC address of the inverter shown by default. The all-zero value is a
  /// placeholder; pass the real address with `--dart-define` when you need it.
  static const String defaultInverterMac = String.fromEnvironment(
    'DEFAULT_INVERTER_MAC',
    defaultValue: '00:00:00:00:00:00',
  );
}

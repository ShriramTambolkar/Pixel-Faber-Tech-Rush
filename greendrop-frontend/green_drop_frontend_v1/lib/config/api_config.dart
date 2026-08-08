import 'package:flutter/foundation.dart';

// Full deployed API URL, including /api. Set at build time, for example:
// flutter build web --dart-define=API_BASE_URL=https://your-api.example.com/api
const String deployedApiBaseUrl = String.fromEnvironment('API_BASE_URL');

// Set with --dart-define=API_HOST=192.168.1.15 for a physical device.
// Keeping this empty makes the safe emulator/local defaults work out of the box.
const String customNetworkIp = String.fromEnvironment('API_HOST');

String get baseUrl {
  if (deployedApiBaseUrl.isNotEmpty) {
    return deployedApiBaseUrl.replaceFirst(RegExp(r'/+$'), '');
  }
  if (kIsWeb) {
    final host = Uri.base.host;
    if (host.isNotEmpty && host != 'localhost' && host != '127.0.0.1') {
      return 'http://$host:5000/api';
    }
    return 'http://127.0.0.1:5000/api';
  }

  // On Physical Android Device or APK, connect via local Wi-Fi network IP
  if (customNetworkIp.isNotEmpty) {
    return 'http://$customNetworkIp:5000/api';
  }

  return 'http://10.0.2.2:5000/api';
}

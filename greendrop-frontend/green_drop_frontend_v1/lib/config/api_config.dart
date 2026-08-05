import 'package:flutter/foundation.dart';
import 'dart:io';

String get baseUrl {
  if (kIsWeb) {
    final host = Uri.base.host;
    if (host.isNotEmpty && host != 'localhost' && host != '127.0.0.1') {
      return 'http://$host:5000/api';
    }
    return 'http://127.0.0.1:5000/api';
  }
  if (Platform.isAndroid) return 'http://10.0.2.2:5000/api';
  return 'http://127.0.0.1:5000/api';
}

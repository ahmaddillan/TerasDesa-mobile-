import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConfig {
  static String get baseUrl {
    // WEB
    if (kIsWeb) {
      return "http://localhost:3000";
    }

    // ANDROID
    if (Platform.isAndroid) {
      // Emulator Android
      return "http://10.0.2.2:3000";
    }

    // iOS Simulator
    if (Platform.isIOS) {
      return "http://localhost:3000";
    }

    // HP FISIK (fallback)
    return "http://192.168.18.120:3000";
  }
}

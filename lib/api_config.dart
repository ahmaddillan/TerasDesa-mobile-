import 'dart:io';

class ApiConfig {
  static String get baseUrl {
    if (Platform.isAndroid) {
      return "http://10.0.2.2:3000";
    }
    return "http://192.168.18.120:3000";
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:terasdesa/api_config.dart';

class ApiService {
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String tanggalLahir,
    required String noHp,
  }) async {
    print("${ApiConfig.baseUrl}");
    final response = await http.post(
      Uri.parse("${ApiConfig.baseUrl}/auth/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": name,
        "email": email,
        "password": password,
        "tanggal_lahir": tanggalLahir,
        "no_hp": noHp,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      return {
        "success": false,
        "message": "Gagal register (${response.statusCode})",
      };
    }
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    print("${ApiConfig.baseUrl}");
    final response = await http.post(
      Uri.parse("${ApiConfig.baseUrl}/auth/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return {"success": false, "message": "Login gagal"};
    }
  }
}

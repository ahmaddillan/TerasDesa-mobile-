import 'dart:convert';
import 'package:http/http.dart' as http;
import '../api_config.dart';

class CheckoutService {
  static Future<Map<String, dynamic>> checkout(
    String token, {
    String? note,
  }) async {
    final res = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/checkout'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'note': note}),
    );

    Map<String, dynamic> body;
    try {
      body = jsonDecode(res.body);
    } catch (_) {
      throw Exception('Server error (${res.statusCode}), response tidak valid');
    }

    if (res.statusCode == 200) {
      return body;
    } else {
      throw Exception(body['message'] ?? 'Checkout gagal');
    }
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../api_config.dart';

class CartService {
  /* ================= GET CART ================= */
  static Future<Map<String, dynamic>> getCart(String token) async {
    final url = '${ApiConfig.baseUrl}/api/cart';

    print('GET CART URL  : $url');
    print('GET CART TOKEN: $token');

    final res = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token'},
    );

    print('GET CART STATUS: ${res.statusCode}');
    print('GET CART BODY  : ${res.body}');

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }

    throw Exception('GET CART FAILED');
  }

  /* ================= ADD TO CART ================= */
  static Future<void> addToCart({
    required String token,
    required int productId,
    int quantity = 1,
    String? note,
  }) async {
    final res = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/cart'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'product_id': productId,
        'quantity': quantity,
        'note': note,
      }),
    );

    if (res.statusCode != 200) {
      throw Exception('ADD TO CART FAILED: ${res.body}');
    }
  }
}

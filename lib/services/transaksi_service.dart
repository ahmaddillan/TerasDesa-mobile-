import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../api_config.dart';
import '../models/transaksi_model.dart';

class TransaksiService {
  static Future<List<TransaksiModel>> fetchTransaksi() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/transaksi'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => TransaksiModel.fromJson(e)).toList();
    } else {
      throw Exception('Gagal mengambil transaksi');
    }
  }
}

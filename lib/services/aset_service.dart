import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../api_config.dart';
import '../models/aset_model.dart';
import 'package:http_parser/http_parser.dart';

class AsetService {
  static String get _baseUrl => "${ApiConfig.baseUrl}/api/assets";

  // Get
  static Future<List<AsetModel>> getAset() async {
    final res = await http.get(Uri.parse(_baseUrl));

    if (res.statusCode == 200) {
      final data = List<Map<String, dynamic>>.from(jsonDecode(res.body));
      return data.map((e) => AsetModel.fromJson(e)).toList();
    }
    throw Exception("Gagal mengambil data");
  }

  // post
  static Future<void> tambahAset({
    required AsetModel aset,
    required File image,
  }) async {
    final uri = Uri.parse(_baseUrl);

    final request = http.MultipartRequest('POST', uri);

    request.headers.addAll({"Accept": "application/json"});

    request.fields.addAll({
      'nama': aset.nama,
      'lokasi': aset.lokasi,
      'status': aset.status,
      'deskripsi': aset.deskripsi,
    });

    request.files.add(
      await http.MultipartFile.fromPath(
        'image',
        image.path,
        contentType: MediaType('image', 'jpeg'),
      ),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 201) {
      throw Exception("Gagal menambah aset: ${response.body}");
    }
  }

  // put
  static Future<void> editAset({
    required int id,
    required AsetModel aset,
    File? image,
  }) async {
    final request = http.MultipartRequest('PUT', Uri.parse("$_baseUrl/$id"));
    request.fields.addAll({
      'nama': aset.nama,
      'lokasi': aset.lokasi,
      'status': aset.status,
      'deskripsi': aset.deskripsi,
    });
    if (image != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'gambar',
          image.path,
          contentType: MediaType('image', 'jpeg'),
        ),
      );
    }
    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    if (response.statusCode != 200) {
      throw Exception("Edit gagal: ${response.body}");
    }
  }

  // delete
  static Future<void> hapusAset(int id) async {
    final res = await http.delete(Uri.parse("$_baseUrl/$id"));
    if (res.statusCode != 200) {
      throw Exception("Gagal hapus");
    }
  }
}

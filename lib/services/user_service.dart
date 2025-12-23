import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  static Future<bool> uploadPhoto(File image) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final uri = Uri.parse("http://192.168.18.120:3000/user/profile/photo");

    final request = http.MultipartRequest("PUT", uri);
    request.headers["Authorization"] = "Bearer $token";

    request.files.add(
      await http.MultipartFile.fromPath(
        "photo",
        image.path,
        contentType: http.MediaType("image", "jpeg"),
      ),
    );

    final response = await request.send();

    if (response.statusCode == 200) {
      final body = await response.stream.bytesToString();
      final json = jsonDecode(body);

      await prefs.setString("user_photo", json["data"]["photo"]);
      return true;
    }

    return false;
  }
}

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:terasdesa/login_page.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'services/user_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String name = "-";
  String email = "-";
  String noHp = "-";
  String tanggalLahir = "-";
  String role = "-";
  String? photo;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  String formatTanggal(String isoDate) {
    if (isoDate.isEmpty || isoDate == "-") return "-";

    try {
      final dateTime = DateTime.parse(isoDate).toLocal();
      return DateFormat('dd MMMM yyyy', 'id').format(dateTime);
    } catch (e) {
      return isoDate;
    }
  }

  Future<void> _pickAndUploadPhoto() async {
    try {
      final picker = ImagePicker();

      final XFile? picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (picked == null) {
        print("USER CANCEL PICK");
        return;
      }

      final file = File(picked.path);

      final success = await UserService.uploadPhoto(file);

      if (!mounted) return;

      if (success) {
        await _loadUser(); // reload prefs
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Foto profil berhasil diperbarui")),
        );
      }
    } catch (e) {
      print("PICK IMAGE ERROR: $e");
    }
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString("user_name") ?? "-";
      email = prefs.getString("user_email") ?? "-";
      noHp = prefs.getString("user_no_hp") ?? "-";
      tanggalLahir = prefs.getString("user_tanggal_lahir") ?? "-";
      role = prefs.getString("user_role") ?? "-";
      photo = prefs.getString("user_photo");
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Akun Saya",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.green[700],
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 24),
            GestureDetector(
              onTap: _pickAndUploadPhoto,
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[300],
                backgroundImage: (photo != null && photo!.isNotEmpty)
                    ? NetworkImage("http://192.168.18.120:3000/$photo")
                    : null,
                child: (photo == null || photo!.isEmpty)
                    ? const Icon(Icons.person, size: 50, color: Colors.white)
                    : null,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            Text(
              role.toUpperCase(),
              style: TextStyle(
                color: role == "admin" ? Colors.red : Colors.green,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 24),

            _infoTile(Icons.email, "Email", email),
            _infoTile(Icons.phone, "No HP", noHp),
            _infoTile(Icons.cake, "Tanggal Lahir", formatTanggal(tanggalLahir)),

            const SizedBox(height: 32),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton(
                onPressed: _logout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  minimumSize: const Size(double.infinity, 45),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Logout",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon, color: Colors.green[700]),
      title: Text(label),
      subtitle: Text(value),
    );
  }
}

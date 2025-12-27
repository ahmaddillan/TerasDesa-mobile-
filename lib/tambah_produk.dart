import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart'; // Solusi untuk error format file
import 'package:path/path.dart' as p; // Solusi untuk error context & path
import 'api_config.dart';

class TambahProdukPage extends StatefulWidget {
  const TambahProdukPage({super.key});

  @override
  State<TambahProdukPage> createState() => _TambahProdukPageState();
}

class _TambahProdukPageState extends State<TambahProdukPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descController = TextEditingController();

  File? _selectedImage;
  bool isLoading = false;

  Future<void> _pickImage(ImageSource source) async {
    final returnedImage = await ImagePicker().pickImage(source: source);
    if (returnedImage != null) {
      setState(() => _selectedImage = File(returnedImage.path));
    }
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Ambil dari Galeri'),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.of(bc).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Ambil dari Kamera'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(bc).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> simpanProduk() async {
    // Validasi Awal
    if (nameController.text.isEmpty ||
        priceController.text.isEmpty ||
        _selectedImage == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Data wajib diisi!")));
      return;
    }

    setState(() => isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      if (token == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Sesi berakhir, silakan login ulang")),
          );
        }
        return;
      }

      final url = Uri.parse('${ApiConfig.baseUrl}/api/products');
      var request = http.MultipartRequest('POST', url);

      // Header dengan Token
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      // Data Form
      request.fields['name'] = nameController.text;
      request.fields['price'] = priceController.text;
      request.fields['description'] = descController.text;

      // PENANGANAN GAMBAR (Agar tidak ditolak formatnya)
      String filePath = _selectedImage!.path;
      String extension = p
          .extension(filePath)
          .replaceAll('.', ''); // ambil 'png' atau 'jpg'

      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          filePath,
          contentType: MediaType(
            'image',
            extension == 'jpg' ? 'jpeg' : extension,
          ),
        ),
      );

      var response = await request.send();
      final responseData = await response.stream.bytesToString();

      // CEK JIKA WIDGET MASIH TERPASANG (Solusi Error Context)
      if (!mounted) return;

      if (response.statusCode == 201 || response.statusCode == 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Berhasil Jual Barang!")));
        Navigator.pop(context, true); // Kembali dan refresh
      } else {
        debugPrint("Error detail: $responseData");
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Gagal Simpan: $responseData")));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error Koneksi: $e")));
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Jual Barang", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green[700],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: () => _showPicker(context),
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: _selectedImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.file(_selectedImage!, fit: BoxFit.cover),
                      )
                    : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_a_photo,
                            size: 50,
                            color: Colors.green,
                          ),
                          Text("Tambah Foto"),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 20),
            _buildTextField(nameController, "Nama Barang", Icons.shopping_bag),
            const SizedBox(height: 15),
            _buildTextField(
              priceController,
              "Harga",
              Icons.money,
              isNumber: true,
            ),
            const SizedBox(height: 15),
            _buildTextField(
              descController,
              "Deskripsi",
              Icons.description,
              maxLines: 4,
            ),
            const SizedBox(height: 30),
            isLoading
                ? const CircularProgressIndicator()
                : SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                      ),
                      onPressed: simpanProduk,
                      child: const Text(
                        "JUAL SEKARANG",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isNumber = false,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.green[700]),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

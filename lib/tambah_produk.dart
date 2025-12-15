import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class TambahProdukPage extends StatefulWidget {
  const TambahProdukPage({super.key});

  @override
  State<TambahProdukPage> createState() => _TambahProdukPageState();
}

class _TambahProdukPageState extends State<TambahProdukPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  File? _selectedImage;
  bool isLoading = false;

  //untuk pilih sumber gambar
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
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Ambil dari Kamera'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  //Fungsi Proses Ambil Gambar
  Future<void> _pickImage(ImageSource source) async {
    final returnedImage = await ImagePicker().pickImage(source: source);
    if (returnedImage != null) {
      setState(() {
        _selectedImage = File(returnedImage.path);
      });
    }
  }

  //Fungsi Kirim ke Laravel
  Future<void> simpanProduk() async {
    if (nameController.text.isEmpty ||
        priceController.text.isEmpty ||
        _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nama, Harga, dan Gambar wajib diisi!")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    final url = Uri.parse('http://10.0.2.2:8000/api/products');

    try {
      var request = http.MultipartRequest('POST', url);

      request.fields['name'] = nameController.text;
      request.fields['price'] = priceController.text;
      request.fields['description'] = descController.text;
      request.fields['seller_location'] = locationController.text;

      request.files.add(
        await http.MultipartFile.fromPath('image', _selectedImage!.path),
      );

      var response = await request.send();

      if (response.statusCode == 201) {
        if (mounted) Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Gagal upload!")));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted)
        setState(() {
          isLoading = false;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Jual Barang"),
        backgroundColor: Colors.green[800],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                //Munculkan pilihan Galeri atau Kamera
                _showPicker(context);
              },
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: _selectedImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(_selectedImage!, fit: BoxFit.cover),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_a_photo,
                            size: 50,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(height: 8),
                          const Text("Tap untuk ambil foto"),
                          const Text(
                            "(Kamera / Galeri)",
                            style: TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Nama Barang",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Harga (Rp)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Deskripsi",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: locationController,
              decoration: const InputDecoration(
                labelText: "Lokasi Penjual",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),

            isLoading
                ? const CircularProgressIndicator()
                : SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[800],
                        foregroundColor: Colors.white,
                      ),
                      onPressed: simpanProduk,
                      child: const Text(
                        "JUAL SEKARANG",
                        style: TextStyle(
                          fontSize: 16,
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
}

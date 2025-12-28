import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/aset_model.dart';
import '../services/aset_service.dart';
import '../api_config.dart';

class AsetPage extends StatefulWidget {
  const AsetPage({super.key});

  @override
  State<AsetPage> createState() => _AsetPageState();
}

class _AsetPageState extends State<AsetPage> {
  List<AsetModel> asetList = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadAset();
  }

  Future<void> loadAset() async {
    try {
      final data = await AsetService.getAset();
      setState(() {
        asetList = data;
        loading = false;
      });
    } catch (_) {
      setState(() => loading = false);
    }
  }

  // Detail Aset
  void showDetail(BuildContext context, AsetModel aset) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        contentPadding: EdgeInsets.zero,
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (aset.gambarUrl != null && aset.gambarUrl!.isNotEmpty)
                  Image.network(
                    "${ApiConfig.baseUrl}/uploads/assets/${aset.gambarUrl}",
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _imageError(),
                  )
                else
                  _imageEmpty(),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        aset.nama,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text("Lokasi: ${aset.lokasi}"),
                      const SizedBox(height: 8),
                      Text("Deskripsi: ${aset.deskripsi}"),
                      const SizedBox(height: 12),
                      Text(
                        "Status: ${aset.status}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: aset.status == 'Tersedia'
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Tutup"),
          ),
        ],
      ),
    );
  }

  // form untuk tambah dan edit
  void showForm({AsetModel? aset}) {
    final isEdit = aset != null;

    final nama = TextEditingController(text: aset?.nama ?? '');
    final lokasi = TextEditingController(text: aset?.lokasi ?? '');
    final deskripsi = TextEditingController(text: aset?.deskripsi ?? '');
    String status = aset?.status ?? 'Tersedia';

    File? selectedImage;
    final picker = ImagePicker();

    Future<void> pickImage(StateSetter setStateDialog) async {
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked != null) {
        setStateDialog(() {
          selectedImage = File(picked.path);
        });
      }
    }

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: Text(isEdit ? "Edit Aset" : "Tambah Aset"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nama,
                  decoration: const InputDecoration(labelText: "Nama"),
                ),
                TextField(
                  controller: lokasi,
                  decoration: const InputDecoration(labelText: "Lokasi"),
                ),
                DropdownButtonFormField(
                  value: status,
                  decoration: const InputDecoration(labelText: "Status"),
                  items: const [
                    DropdownMenuItem(
                      value: 'Tersedia',
                      child: Text('Tersedia'),
                    ),
                    DropdownMenuItem(
                      value: 'Tidak Tersedia',
                      child: Text('Tidak Tersedia'),
                    ),
                  ],
                  onChanged: (v) => status = v!,
                ),
                TextField(
                  controller: deskripsi,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: "Deskripsi"),
                ),
                const SizedBox(height: 12),

                // PREVIEW GAMBAR
                if (selectedImage != null)
                  Image.file(selectedImage!, height: 120)
                else if (isEdit &&
                    aset!.gambarUrl != null &&
                    aset.gambarUrl!.isNotEmpty)
                  Image.network(
                    "${ApiConfig.baseUrl}/uploads/assets/${aset.gambarUrl}",
                    height: 120,
                    errorBuilder: (_, __, ___) => _imageError(),
                  ),

                TextButton.icon(
                  onPressed: () => pickImage(setStateDialog),
                  icon: const Icon(Icons.image),
                  label: const Text("Pilih Gambar"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              child: const Text("Simpan"),
              onPressed: () async {
                try {
                  if (!isEdit && selectedImage == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Gambar wajib dipilih")),
                    );
                    return;
                  }

                  final data = AsetModel(
                    id: aset?.id,
                    nama: nama.text.trim(),
                    lokasi: lokasi.text.trim(),
                    status: status,
                    gambarUrl: aset?.gambarUrl,
                    deskripsi: deskripsi.text.trim(),
                  );

                  if (isEdit) {
                    await AsetService.editAset(
                      id: aset!.id!,
                      aset: data,
                      image: selectedImage,
                    );
                  } else {
                    await AsetService.tambahAset(
                      aset: data,
                      image: selectedImage!,
                    );
                  }

                  Navigator.pop(context);
                  await loadAset();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Aset berhasil disimpan")),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(e.toString())));
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  //Konfirmasi hapus aset
  void confirmDelete(BuildContext context, AsetModel aset) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Hapus Aset"),
        content: Text("Yakin ingin menghapus '${aset.nama}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await AsetService.hapusAset(aset.id!);
              Navigator.pop(context);
              loadAset();
            },
            child: const Text("Hapus"),
          ),
        ],
      ),
    );
  }

  //ui
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Aset Desa",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green[700],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: asetList.length,
              itemBuilder: (_, i) {
                final a = asetList[i];

                return Card(
                  margin: const EdgeInsets.all(12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (a.gambarUrl != null && a.gambarUrl!.isNotEmpty)
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                          child: Image.network(
                            "${ApiConfig.baseUrl}/uploads/assets/${a.gambarUrl}",
                            height: 160,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _imageError(),
                          ),
                        ),

                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    a.nama,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "Status: ${a.status}",
                                    style: TextStyle(
                                      color: a.status == 'Tersedia'
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.info, color: Colors.green),
                              onPressed: () => showDetail(context, a),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.edit,
                                color: Colors.orange,
                              ),
                              onPressed: () => showForm(aset: a),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => confirmDelete(context, a),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
      // tombol tambah aset
      floatingActionButton: FloatingActionButton(
        onPressed: () => showForm(),
        child: const Icon(Icons.add),
      ),
    );
  }

  //error handle
  Widget _imageError() => Container(
    height: 160,
    color: Colors.grey[300],
    alignment: Alignment.center,
    child: const Text("Gagal memuat gambar"),
  );

  Widget _imageEmpty() => Container(
    height: 160,
    color: Colors.grey[300],
    alignment: Alignment.center,
    child: const Text("Tidak ada gambar"),
  );
}

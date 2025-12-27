import 'package:flutter/material.dart';

class AsetPage extends StatefulWidget {
  const AsetPage({super.key});

  @override
  State<AsetPage> createState() => _AsetPageState();
}

class _AsetPageState extends State<AsetPage> {
  final List<Map<String, dynamic>> asetDesa = [
    {
      'nama': 'Balai Desa',
      'lokasi': 'Pusat Desa',
      'status': 'Tersedia',
      'gambar_url':
          'https://cdn.digitaldesa.com/uploads/profil/32.01.02.2009/spanduk/396b9ba14698b0b96671172b7a23d7ba.png',
      'deskripsi': 'Gedung utama untuk administrasi dan pertemuan desa.',
    },
    {
      'nama': 'Mobil Operasional Desa',
      'lokasi': 'Garasi Kantor Desa',
      'status': 'Tidak Tersedia',
      'gambar_url':
          'https://img.icarcdn.com/mobil123-news/body/67281-suzuki_apv_1.5_sgx_arena_van_silver_2010.jpg',
      'deskripsi': 'Kendaraan siaga untuk keperluan operasional dan darurat.',
    },
    {
      'nama': 'Aula',
      'lokasi': 'Kantor Desa',
      'status': 'Tersedia',
      'gambar_url':
          'https://beritacianjur.com/wp-content/uploads/2021/07/WhatsApp-Image-2021-07-07-at-19.05.40.jpeg',
      'deskripsi': 'Ruang serbaguna untuk acara besar desa.',
    },
  ];

  // ===================== DETAIL DIALOG =====================
  void _showAsetDialog(BuildContext context, Map<String, dynamic> aset) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: EdgeInsets.zero,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: Image.network(
                aset['gambar_url'],
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 150,
                  color: Colors.grey[300],
                  child: const Center(child: Text('Gagal memuat gambar')),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    aset['nama'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(),
                  Text("Lokasi: ${aset['lokasi']}"),
                  const SizedBox(height: 8),
                  Text("Deskripsi: ${aset['deskripsi']}"),
                  const SizedBox(height: 12),
                  Text(
                    "Status: ${aset['status']}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: aset['status'] == 'Tersedia'
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  // ===================== FORM TAMBAH / EDIT =====================
  void _showFormAset(
    BuildContext context, {
    Map<String, dynamic>? aset,
    int? index,
  }) {
    final nama = TextEditingController(text: aset?['nama'] ?? '');
    final lokasi = TextEditingController(text: aset?['lokasi'] ?? '');
    final gambar = TextEditingController(text: aset?['gambar_url'] ?? '');
    final deskripsi = TextEditingController(text: aset?['deskripsi'] ?? '');
    String status = aset?['status'] ?? 'Tersedia';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(aset == null ? 'Tambah Aset' : 'Edit Aset'),
        content: StatefulBuilder(
          builder: (context, setStateDialog) => SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nama,
                  decoration: const InputDecoration(labelText: 'Nama Aset'),
                ),
                TextField(
                  controller: lokasi,
                  decoration: const InputDecoration(labelText: 'Lokasi'),
                ),
                DropdownButtonFormField(
                  value: status,
                  decoration: const InputDecoration(labelText: 'Status'),
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
                  onChanged: (v) => setStateDialog(() => status = v!),
                ),
                TextField(
                  controller: gambar,
                  decoration: const InputDecoration(labelText: 'URL Gambar'),
                ),
                TextField(
                  controller: deskripsi,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Deskripsi'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                final data = {
                  'nama': nama.text,
                  'lokasi': lokasi.text,
                  'status': status,
                  'gambar_url': gambar.text,
                  'deskripsi': deskripsi.text,
                };
                if (aset == null) {
                  asetDesa.add(data);
                } else {
                  asetDesa[index!] = data;
                }
              });
              Navigator.pop(context);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  // ===================== HAPUS =====================
  void _confirmDelete(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Aset'),
        content: const Text('Yakin ingin menghapus aset ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              setState(() => asetDesa.removeAt(index));
              Navigator.pop(context);
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  // ===================== UI =====================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Aset Desa',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.green[700],
      ),
      body: ListView.builder(
        itemCount: asetDesa.length,
        itemBuilder: (context, index) {
          final aset = asetDesa[index];
          return Card(
            margin: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(
                  aset['gambar_url'],
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
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
                              aset['nama'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "Status: ${aset['status']}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: aset['status'] == 'Tersedia'
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orange),
                        onPressed: () =>
                            _showFormAset(context, aset: aset, index: index),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDelete(context, index),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.info_outline,
                          color: Colors.green,
                        ),
                        onPressed: () => _showAsetDialog(context, aset),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green[700],
        onPressed: () => _showFormAset(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}

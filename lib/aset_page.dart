import 'package:flutter/material.dart';
import 'package:terasdesa/homepage.dart';
import 'package:terasdesa/marketplace_page.dart';

class AsetPage extends StatefulWidget {
  const AsetPage({super.key});

  @override
  State<AsetPage> createState() => _AsetPageState();
}

//isi dari aset (dummy)
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

  //navigasi pages
  int _selectedIndex = 1;

  //Show detail aset
  void _showAsetDialog(BuildContext context, Map<String, dynamic> aset) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.all(0),
          // isi dialog
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // muncul gambar di dialog
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: SizedBox(
                  height: 150,
                  width: double.infinity,
                  // nampilin gambar aset
                  child: Image.network(
                    aset['gambar_url'],
                    fit: BoxFit.cover,
                    loadingBuilder:
                        (
                          BuildContext context,
                          Widget child,
                          ImageChunkEvent? loadingProgress,
                        ) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[300],
                      alignment: Alignment.center,
                      child: const Text(
                        'Gagal memuat gambar',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      aset['nama'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const Divider(),
                    // Lokasi dan Deskripsi di dalam Dialog
                    Text("Lokasi: ${aset['lokasi']}"),
                    const SizedBox(height: 8),
                    Text(
                      "Deskripsi: ${aset['deskripsi'] ?? 'Tidak ada deskripsi'}",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Status: ${aset['status']}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        // status ketersediaan aset
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
            // menutup dialog
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Tutup', style: TextStyle(color: Colors.green)),
            ),
          ],
        );
      },
    );
  }

  //form edit dan tambah aset
  void _showFormAset(
    BuildContext context, {
    Map<String, dynamic>? aset,
    int? index,
  }) {
    final namaController = TextEditingController(text: aset?['nama'] ?? '');
    final lokasiController = TextEditingController(text: aset?['lokasi'] ?? '');
    final gambarController = TextEditingController(
      text: aset?['gambar_url'] ?? '',
    );
    final deskripsiController = TextEditingController(
      text: aset?['deskripsi'] ?? '',
    );

    String status = aset?['status'] ?? 'Tersedia';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(aset == null ? 'Tambah Aset' : 'Edit Aset'),
        content: StatefulBuilder(
          builder: (context, setStateDialog) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: namaController,
                    decoration: const InputDecoration(labelText: 'Nama Aset'),
                  ),
                  TextField(
                    controller: lokasiController,
                    decoration: const InputDecoration(labelText: 'Lokasi Aset'),
                  ),
                  DropdownButtonFormField<String>(
                    value: status,
                    decoration: const InputDecoration(labelText: 'Status Aset'),
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
                    onChanged: (value) {
                      setStateDialog(() {
                        status = value!;
                      });
                    },
                  ),
                  TextField(
                    controller: gambarController,
                    decoration: const InputDecoration(labelText: 'URL Gambar'),
                  ),
                  TextField(
                    controller: deskripsiController,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'Deskripsi'),
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              setState(() {
                final data = {
                  'nama': namaController.text,
                  'lokasi': lokasiController.text,
                  'status': status,
                  'gambar_url': gambarController.text,
                  'deskripsi': deskripsiController.text,
                };

                if (aset == null) {
                  asetDesa.add(data);
                } else {
                  asetDesa[index!] = data;
                }
              });
              Navigator.pop(context);
            },
            child: const Text('Simpan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  //komfirmasi hapus aset
  void _confirmDelete(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Aset'),
        content: const Text('Apakah yakin ingin menghapus aset ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8), // TIDAK TERLALU BULAT
              ),
            ),
            onPressed: () {
              setState(() {
                asetDesa.removeAt(index);
              });

              Navigator.pop(context);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  //tampilan
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          tooltip: 'Kembali',
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Homepage()),
            );
          },
        ),

        title: const Text(
          'Aset Desa',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.green[700],
      ),

      body: ListView.builder(
        itemCount: asetDesa.length,
        itemBuilder: (context, index) {
          final aset = asetDesa[index];

          return Card(
            margin: const EdgeInsets.all(12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                            const SizedBox(height: 4),
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
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // tombol HAPUS
                          ElevatedButton(
                            onPressed: () => _confirmDelete(context, index),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            child: const Text(
                              'Hapus',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),

                          const SizedBox(width: 8),

                          // tombol EDIT
                          ElevatedButton(
                            onPressed: () => _showFormAset(
                              context,
                              aset: aset,
                              index: index,
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            child: const Text(
                              'Edit',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),

                          const SizedBox(width: 8),

                          // tombol DETAIL
                          ElevatedButton(
                            onPressed: () => _showAsetDialog(context, aset),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[600],
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            child: const Text(
                              'Detail',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
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
        child: const Icon(Icons.add, color: Colors.white),
      ),

      //berpindah page menggunakan bottom navbar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green[700],
        onTap: (index) {
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MarketplacePage()),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Homepage()),
            );
          } else if (index == 2) {
            // Navigator.push(
            //     context,
            //     MaterialPageRoute(
            //       builder: (context) => const profile_page(),
            //     ),
            //   );
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront),
            label: 'Market',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Akun'),
        ],
      ),
    );
  }
}

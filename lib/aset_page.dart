import 'package:flutter/material.dart';


class AsetPage extends StatefulWidget {
  const AsetPage({super.key});

  @override
  State<AsetPage> createState() => _AsetPageState();
}

class _AsetPageState extends State<AsetPage> {
  // Data aset desa 
  final List<Map<String, dynamic>> asetDesa = [
    { 
      'nama': 'Balai Desa', 
      'lokasi': 'Pusat Desa', 
      'status': 'Tersedia', 
      'gambar_url': 'https://cdn.digitaldesa.com/uploads/profil/32.01.02.2009/spanduk/396b9ba14698b0b96671172b7a23d7ba.png', 
      'deskripsi': 'Gedung utama untuk administrasi dan pertemuan desa.', 
    },
    { 
      'nama': 'Mobil Operasional Desa', 
      'lokasi': 'Garasi Kantor Desa', 
      'status': 'Tidak Tersedia', 
      'gambar_url': 'https://img.icarcdn.com/mobil123-news/body/67281-suzuki_apv_1.5_sgx_arena_van_silver_2010.jpg', 
      'deskripsi': 'Kendaraan siaga untuk keperluan operasional dan darurat.', 
    },
    { 
      'nama': 'Aula', 
      'lokasi': 'Kantor Desa', 
      'status': 'Tersedia', 
      'gambar_url': 'https://beritacianjur.com/wp-content/uploads/2021/07/WhatsApp-Image-2021-07-07-at-19.05.40.jpeg', 
      'deskripsi': 'Ruang serbaguna untuk acara besar desa.', 
    },
    { 
      'nama': 'Kursi Pesta', 
      'lokasi': 'Gudang Kantor Desa', 
      'status': 'Tidak Tersedia', 
      'gambar_url': 'https://sosialita.tanahlautkab.go.id/assets/uploads/webp/fotoproduk/thumbs/pt4K3vJE20250722130019.jpg.webp', 
      'deskripsi': 'Stok kursi plastik untuk acara dan sewa masyarakat.', 
    },
    { 
      'nama': 'Sound System', 
      'lokasi': 'Kantor Desa', 
      'status': 'Tersedia', 
      'gambar_url': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRQsrddQT6x3ZOMx-MiD5VN1r8tTZcVt9i3hszSI25L7MSXH0nF-EOlG1lmt7YbU2q_18c&usqp=CAU', 
      'deskripsi': 'Sistem suara portable untuk acara outdoor/indoor.',
    },
    { 
      'nama': 'Tenda', 
      'lokasi': 'Kantor Desa', 
      'status': 'Tersedia', 
      'gambar_url': 'https://image-asset.parto.id/i/1B/3e0cb4f938176cd98e874591894d2095.jpg', 
      'deskripsi': 'Tenda serbaguna (ukuran 5x5m) untuk acara desa.', 
    },
    { 
      'nama': 'Keranda Jenazah', 
      'lokasi': 'Gudang Alat Desa', 
      'status': 'Tersedia', 
      'gambar_url': 'https://encrypted-tbn1.gstatic.com/images?q=tbn:ANd9GcQCJ6zreErtvBj-qLdiXKyPm8TnZPWm8ozCm-O_iTbgu8IlIPou', 
      'deskripsi': 'Keranda Stainless Steel untuk keperluan pemakaman.', 
    },
  ];

  int _selectedIndex = 1; 

  void _onNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 1) {
      if (ModalRoute.of(context)?.isFirst == false) {
        Navigator.pop(context); 
      }
    } else if (index == 0) {
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(builder: (context) => const MarketPage()),
      // );
    } else if (index == 2) {
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(builder: (context) => const AkunPage()),
      // );
    }
  }

  // Fungsi untuk menampilkan Dialog Ketersediaan 
  void _showAsetDialog(BuildContext context, Map<String, dynamic> aset) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.all(0),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // muncul gambar di dialog
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: SizedBox(
                  height: 150,
                  width: double.infinity,
                  child: Image.network(
                    aset['gambar_url'], 
                    fit: BoxFit.cover,
                    loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes! : null,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[300],
                      alignment: Alignment.center,
                      child: const Text('Gagal memuat gambar', style: TextStyle(color: Colors.grey)),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(aset['nama'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    const Divider(),
                    // Lokasi dan Deskripsi di dalam Dialog
                    Text("Lokasi: ${aset['lokasi']}"), 
                    const SizedBox(height: 8),
                    Text("Deskripsi: ${aset['deskripsi'] ?? 'Tidak ada deskripsi'}", style: const TextStyle(fontSize: 14, color: Colors.black54)),
                    const SizedBox(height: 12),
                    Text(
                      "Status: ${aset['status']}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: aset['status'] == 'Tersedia' ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Tutup', style: TextStyle(color: Colors.green)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Aset Desa',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.green[700],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        color: Colors.grey[100],
        child: ListView.builder(
          itemCount: asetDesa.length,
          itemBuilder: (context, index) {
            final aset = asetDesa[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: Image.network(
                      aset['gambar_url'], 
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 150,
                          color: Colors.grey[200],
                          alignment: Alignment.center,
                          child: const CircularProgressIndicator(color: Colors.green),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 150,
                        color: Colors.grey[300],
                        alignment: Alignment.center,
                        child: const Icon(Icons.broken_image, size: 40, color: Colors.grey),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
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
                              const SizedBox(height: 4),
                              Text(
                                'Status: ${aset['status']}',
                                style: TextStyle(
                                  fontSize: 14, 
                                  fontWeight: FontWeight.bold,
                                  color: aset['status'] == 'Tersedia' ? Colors.green : Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(width: 16),
                        
                        // Tombol "Detail"
                        ElevatedButton(
                          onPressed: () {
                            _showAsetDialog(context, aset);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[600],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Detail',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green[700],
        unselectedItemColor: Colors.grey,
        onTap: _onNavTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.storefront_outlined), label: 'Market'),
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Akun'),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'api_config.dart';
import 'models/produk_model.dart';
import 'detailproduk.dart';

class HomePage extends StatefulWidget {
  // Fungsi callback untuk berpindah tab di MainPage
  final Function(int) onTabChange;

  const HomePage({super.key, required this.onTabChange});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<ProdukModel>> _homeData;

  @override
  void initState() {
    super.initState();
    _homeData = fetchHomeProducts();
  }

  Future<List<ProdukModel>> fetchHomeProducts() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/products'),
      );
      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        List productsJson = (decodedData is Map)
            ? (decodedData['data'] ?? [])
            : decodedData;
        // Kita hanya ambil 3 produk terbaru untuk ditampilkan di home
        return productsJson
            .map((item) => ProdukModel.fromJson(item))
            .toList()
            .take(3)
            .toList();
      } else {
        throw Exception('Gagal muat data');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        elevation: 0,
        title: const Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white24,
              child: Icon(Icons.person, color: Colors.white),
            ),
            SizedBox(width: 10),
            Text(
              "Selamat datang di TerasDesa",
              style: TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. MENU AKSES CEPAT
            _buildCategoryMenu(),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                "Kabar Terbaru Desa",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            _buildPembangunanCard(),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Text(
                "Produk Unggulan",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            _buildMarketplaceSection(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryMenu() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // TOMBOL ASET
          _categoryItem(
            icon: Icons.account_balance_wallet,
            label: "Aset Desa",
            color: Colors.green,
            onTap: () => widget.onTabChange(1), // Pindah ke Tab Aset (Index 1)
          ),

          // TOMBOL PEMBANGUNAN
          _categoryItem(
            icon: Icons.construction,
            label: "Pembangunan",
            color: Colors.orange,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Fitur Pembangunan sedang dikembangkan"),
                ),
              );
            },
          ),

          // TOMBOL MARKETPLACE
          _categoryItem(
            icon: Icons.store,
            label: "Marketplace",
            color: Colors.blue,
            onTap: () =>
                widget.onTabChange(0), // Pindah ke Tab Market (Index 0)
          ),
        ],
      ),
    );
  }

  Widget _categoryItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                Icon(icon, color: color, size: 30),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPembangunanCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(15),
              ),
              image: const DecorationImage(
                image: NetworkImage("https://via.placeholder.com/400x200"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "PROYEK DESA",
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  "Renovasi Jembatan Desa",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  "Progres saat ini: 45%. Target selesai akhir tahun.",
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarketplaceSection() {
    return FutureBuilder<List<ProdukModel>>(
      future: _homeData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("Belum ada produk unggulan"));
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final item = snapshot.data![index];
            return _buildHomeProductCard(item);
          },
        );
      },
    );
  }

  Widget _buildHomeProductCard(ProdukModel item) {
    String getImageUrl(String? path) {
      if (path == null || path.isEmpty) return "";
      if (!path.contains('/products/')) {
        path = path.replaceFirst('/uploads/', '/uploads/products/');
      }
      return '${ApiConfig.baseUrl}$path';
    }

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (c) => DetailProduk(produk: item)),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(12),
              ),
              child: Image.network(
                getImageUrl(item.imageUrl),
                height: 80,
                width: 80,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => const Icon(Icons.broken_image),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  "Rp ${item.price.toStringAsFixed(0)}",
                  style: TextStyle(
                    color: Colors.green[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'api_config.dart';
import 'models/produk_model.dart';
import 'detailproduk.dart';
import 'tambah_produk.dart';
import 'wishlist_page.dart';
import 'cart_page.dart';
import 'transaksi_page.dart';

class MarketplacePage extends StatefulWidget {
  const MarketplacePage({super.key});

  @override
  _MarketplacePageState createState() => _MarketplacePageState();
}

class _MarketplacePageState extends State<MarketplacePage> {
  List<ProdukModel> _allProducts = [];
  List<ProdukModel> _filteredProducts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData(); // Memuat data saat pertama kali buka
  }

  // Fungsi utama untuk mengambil data dari API
  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/products'),
      );
      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        List productsJson = (decodedData is Map)
            ? (decodedData['data'] ?? [])
            : decodedData;

        if (mounted) {
          setState(() {
            _allProducts = productsJson
                .map((item) => ProdukModel.fromJson(item))
                .toList();
            _filteredProducts = _allProducts;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Error Fetch: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Fungsi khusus untuk RefreshIndicator (harus mengembalikan Future)
  Future<void> _onRefresh() async {
    await _fetchData();
  }

  String _getImageUrl(String? path) {
    if (path == null || path.isEmpty) return "";
    if (!path.contains('/products/')) {
      path = path.replaceFirst('/uploads/', '/uploads/products/');
    }
    return '${ApiConfig.baseUrl}$path';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            onChanged: (value) {
              setState(() {
                _filteredProducts = _allProducts
                    .where(
                      (p) => p.name.toLowerCase().contains(value.toLowerCase()),
                    )
                    .toList();
              });
            },
            decoration: const InputDecoration(
              hintText: "Cari produk desa...",
              prefixIcon: Icon(Icons.search, color: Colors.grey),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.white),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (c) => const WishlistPage()),
            ),
          ),

          /// 🛒 KERANJANG
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CartPage()),
              );
            },
          ),

          /// 📦 TRANSAKSI
          IconButton(
            icon: const Icon(Icons.receipt_long_outlined, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TransaksiPage()),
              );
            },
          ),
        ],
      ),
      // MENGGUNAKAN REFRESH INDICATOR UNTUK GESTUR SCROLL KEATAS
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: Colors.green[700],
        child: _isLoading && _allProducts.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : _filteredProducts.isEmpty
            ? ListView(
                // Gunakan ListView agar tetap bisa di-pull refresh saat kosong
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                  const Center(child: Text("Produk tidak ditemukan")),
                ],
              )
            : GridView.builder(
                padding: const EdgeInsets.all(12),
                // AlwaysScrollableScrollPhysics agar bisa ditarik meski item sedikit
                physics: const AlwaysScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: _filteredProducts.length,
                itemBuilder: (context, index) {
                  final item = _filteredProducts[index];
                  return GestureDetector(
                    onTap: () async {
                      // MENUNGGU HASIL DARI HALAMAN DETAIL
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (c) => DetailProduk(produk: item),
                        ),
                      );
                      // Jika result adalah true (setelah hapus), refresh otomatis
                      if (result == true) {
                        _fetchData();
                      }
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),
                              child: Image.network(
                                _getImageUrl(item.imageUrl),
                                fit: BoxFit.cover,
                                width: double.infinity,
                                errorBuilder: (c, e, s) =>
                                    const Icon(Icons.broken_image),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
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
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green[700],
        onPressed: () async {
          final isAdded = await Navigator.push(
            context,
            MaterialPageRoute(builder: (c) => const TambahProdukPage()),
          );
          if (isAdded == true) _fetchData();
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

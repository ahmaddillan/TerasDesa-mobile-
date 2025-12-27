import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_config.dart';
import 'models/wishlist_model.dart';
import 'detailproduk.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  List<WishlistModel> _allWishlist = [];
  List<WishlistModel> _filteredWishlist = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchWishlist();
  }

  // Fungsi ambil data & refresh
  Future<void> _fetchWishlist() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/wishlist'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        List data = decodedData['data'] ?? [];
        if (mounted) {
          setState(() {
            _allWishlist = data
                .map((item) => WishlistModel.fromJson(item))
                .toList();
            _filteredWishlist = _allWishlist;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Error Wishlist: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // FUNGSI HAPUS DARI WISHLIST
  Future<void> _removeFromWishlist(int productId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/api/wishlist/$productId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Berhasil dihapus dari wishlist")),
          );
          _fetchWishlist(); // Refresh data otomatis
        }
      }
    } catch (e) {
      debugPrint("Delete Wishlist Error: $e");
    }
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
        title: const Text(
          "Wishlist Saya",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green[700],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchWishlist,
        color: Colors.green[700],
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _filteredWishlist = _allWishlist
                        .where(
                          (w) => w.produk.name.toLowerCase().contains(
                            value.toLowerCase(),
                          ),
                        )
                        .toList();
                  });
                },
                decoration: InputDecoration(
                  hintText: "Cari di wishlist...",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // Grid Wishlist
            Expanded(
              child: _isLoading && _allWishlist.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredWishlist.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.2,
                        ),
                        const Center(child: Text("Wishlist kosong")),
                      ],
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      physics: const AlwaysScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.65,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                      itemCount: _filteredWishlist.length,
                      itemBuilder: (context, index) {
                        final wish = _filteredWishlist[index];
                        final prod = wish.produk;
                        return _buildWishlistCard(prod);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWishlistCard(prod) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (c) => DetailProduk(produk: prod)),
        );
        if (result == true) _fetchWishlist();
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: Image.network(
                    _getImageUrl(prod.imageUrl),
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => const Icon(Icons.broken_image),
                  ),
                ),
                // TOMBOL TIGA TITIK (PopupMenu)
                Positioned(
                  top: 5,
                  right: 5,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      shape: BoxShape.circle,
                    ),
                    child: PopupMenuButton<String>(
                      icon: const Icon(
                        Icons.more_vert,
                        size: 20,
                        color: Colors.black87,
                      ),
                      onSelected: (value) {
                        if (value == 'delete') {
                          _removeFromWishlist(prod.id);
                        }
                      },
                      itemBuilder: (BuildContext context) => [
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text("Hapus dari Wishlist"),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    prod.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Rp ${prod.price.toStringAsFixed(0)}",
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Desa Nagrak",
                    style: TextStyle(color: Colors.grey, fontSize: 10),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

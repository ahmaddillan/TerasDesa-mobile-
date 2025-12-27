import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_config.dart';
import 'models/produk_model.dart';

class DetailProduk extends StatefulWidget {
  final ProdukModel produk;
  const DetailProduk({super.key, required this.produk});

  @override
  State<DetailProduk> createState() => _DetailProdukState();
}

class _DetailProdukState extends State<DetailProduk> {
  int? currentUserId;
  bool isWishlisted = false;
  bool isLoading = false; // Untuk indikator loading saat menghapus
  final TextEditingController _catatanController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _checkWishlistStatus();
  }

  @override
  void dispose() {
    _catatanController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => currentUserId = prefs.getInt('user_id'));
  }

  Future<void> _checkWishlistStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final response = await http.get(
        Uri.parse(
          '${ApiConfig.baseUrl}/api/wishlist/check/${widget.produk.id}',
        ),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() => isWishlisted = data['isWishlisted'] ?? false);
      }
    } catch (e) {
      debugPrint("Check Wishlist Error: $e");
    }
  }

  // FUNGSI HAPUS LISTING (FIXED)
  Future<void> _deleteProduct() async {
    setState(() => isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/api/products/${widget.produk.id}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (mounted) {
        if (response.statusCode == 200 || response.statusCode == 204) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Produk berhasil dihapus")),
          );
          Navigator.pop(
            context,
            true,
          ); // Kembali ke marketplace & kirim sinyal refresh
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Gagal menghapus produk")),
          );
        }
      }
    } catch (e) {
      debugPrint("Delete Error: $e");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Listing?"),
        content: const Text(
          "Apakah Anda yakin ingin menghapus barang ini dari marketplace?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteProduct();
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleWishlist() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    try {
      if (isWishlisted) {
        await http.delete(
          Uri.parse('${ApiConfig.baseUrl}/api/wishlist/${widget.produk.id}'),
          headers: {'Authorization': 'Bearer $token'},
        );
        setState(() => isWishlisted = false);
      } else {
        await http.post(
          Uri.parse('${ApiConfig.baseUrl}/api/wishlist'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: json.encode({'product_id': widget.produk.id}),
        );
        setState(() => isWishlisted = true);
      }
    } catch (e) {
      debugPrint("Toggle Wishlist Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isMyProduct = currentUserId == widget.produk.userId;

    String getFullImageUrl() {
      if (widget.produk.imageUrl == null) return "";
      String path = widget.produk.imageUrl!;
      if (!path.contains('/products/')) {
        path = path.replaceFirst('/uploads/', '/uploads/products/');
      }
      return '${ApiConfig.baseUrl}$path';
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Detail Produk",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green[700],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 350,
                    width: double.infinity,
                    color: Colors.grey[100],
                    child: widget.produk.imageUrl != null
                        ? Image.network(
                            getFullImageUrl(),
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) =>
                                const Icon(Icons.broken_image, size: 100),
                          )
                        : const Icon(Icons.image, size: 100),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.produk.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Rp ${widget.produk.price.toStringAsFixed(0)}",
                          style: TextStyle(
                            fontSize: 22,
                            color: Colors.green[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(height: 30),
                        const Text(
                          "Deskripsi Produk",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.produk.description,
                          style: const TextStyle(height: 1.5),
                        ),
                        const SizedBox(height: 25),
                        const Divider(),
                        if (!isMyProduct) ...[
                          const Text(
                            "Catatan Pesanan",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _catatanController,
                            decoration: InputDecoration(
                              hintText: "Contoh: Warna merah, ukuran L",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          const SizedBox(height: 25),
                          const Divider(),
                        ],
                        const Text(
                          "Informasi Penjual",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.green[100],
                              radius: 25,
                              child: Icon(
                                Icons.storefront,
                                color: Colors.green[700],
                              ),
                            ),
                            const SizedBox(width: 15),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Warga Desa Nagrak",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  "Desa Nagrak, Kec. Cangkuang",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 10),
          ],
        ),
        child: Row(
          children: [
            if (!isMyProduct) ...[
              GestureDetector(
                onTap: _toggleWishlist,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isWishlisted ? Colors.red : Colors.grey[400]!,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isWishlisted ? Icons.favorite : Icons.favorite_border,
                    color: isWishlisted ? Colors.red : Colors.grey,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.green),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.shopping_cart_outlined,
                    color: Colors.green,
                  ),
                  onPressed: () {},
                ),
              ),
              const SizedBox(width: 15),
            ],
            Expanded(
              child: ElevatedButton(
                onPressed: isMyProduct ? _confirmDelete : () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: isMyProduct
                      ? Colors.red[700]
                      : Colors.green[700],
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  isMyProduct ? "HAPUS LISTING" : "BELI SEKARANG",
                  style: const TextStyle(
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
}

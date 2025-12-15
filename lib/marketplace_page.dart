import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

import 'detailproduk.dart';
import 'models/produk_model.dart';
import 'tambah_produk.dart';

class MarketplacePage extends StatefulWidget {
  const MarketplacePage({super.key});

  @override
  State<MarketplacePage> createState() => _MarketplacePageState();
}

class _MarketplacePageState extends State<MarketplacePage> {
  int _selectedIndex = 0;
  List<Produk> listProduk = [];
  bool isLoading = true;

  //Controller untuk Search Bar
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchProducts(); // Ambil semua data saat awal
  }

  void _onItemTapped(int index) {
    if (index == 1) Navigator.pop(context);
  }

  //fungsi agar bisa menerima kata kunci
  Future<void> fetchProducts([String? query]) async {
    setState(() {
      isLoading = true;
    });

    // Base URL
    String urlString = 'http://10.0.2.2:8000/api/products';

    // Jika ada pencarian, tambahkan query parameter
    if (query != null && query.isNotEmpty) {
      urlString += '?name=$query';
    }

    final url = Uri.parse(urlString);

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List data = jsonResponse['data'];
        setState(() {
          listProduk = data.map((item) => Produk.fromJson(item)).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  String formatRupiah(int price) {
    return NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(price);
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor != Colors.blue
        ? Theme.of(context).primaryColor
        : Colors.green[800]!;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: primaryColor,
        automaticallyImplyLeading: false,
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: _searchController,
            textInputAction:
                TextInputAction.search, // Tombol enter jadi ikon search
            onSubmitted: (value) {
              fetchProducts(value); // Panggil API saat tekan Enter
            },
            decoration: InputDecoration(
              hintText: 'Cari Produk yang dijual?',
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear, color: Colors.grey, size: 20),
                onPressed: () {
                  _searchController.clear();
                  fetchProducts(); // Reset list saat tombol X ditekan
                },
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TambahProdukPage()),
          );
          if (result == true) {
            fetchProducts();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Produk Berhasil Ditambahkan!")),
            );
          }
        },
      ),

      body: isLoading
          ? Center(child: CircularProgressIndicator(color: primaryColor))
          : RefreshIndicator(
              onRefresh: () => fetchProducts(_searchController.text),
              color: primaryColor,
              child: listProduk.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.3,
                        ),
                        const Center(
                          child: Text(
                            "Produk tidak ditemukan.",
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        ),
                      ],
                    )
                  : GridView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.7,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                          ),
                      itemCount: listProduk.length,
                      itemBuilder: (context, index) {
                        final produk = listProduk[index];
                        return GestureDetector(
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    Detailproduk(produk: produk),
                              ),
                            );
                            if (result == true) {
                              fetchProducts();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Daftar diperbarui"),
                                ),
                              );
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(10),
                                    ),
                                    child: Image.network(
                                      produk.imageUrl,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (c, o, s) => const Icon(
                                        Icons.broken_image,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        produk.name,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        formatRupiah(produk.price),
                                        style: TextStyle(
                                          color: primaryColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        produk.sellerLocation,
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey,
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

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey[600],
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront),
            label: 'Market',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Akun',
          ),
        ],
      ),
    );
  }
}

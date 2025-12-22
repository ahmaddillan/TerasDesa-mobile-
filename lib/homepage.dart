import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:terasdesa/login_page.dart';
import 'package:terasdesa/aset_page.dart';
import 'package:terasdesa/marketplace_page.dart';
import 'package:terasdesa/detailproduk.dart';
import 'package:terasdesa/models/produk_model.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int _selectedIndex = 1;
  Produk? _randomProduct;
  bool _isLoadingProduct = true;

  @override
  void initState() {
    super.initState();
    _fetchRandomProduct();
  }

  String formatRupiah(int price) {
    return NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(price);
  }

  Future<void> _handleRefresh() async {
    await _fetchRandomProduct();
    await Future.delayed(const Duration(seconds: 1));
  }

  Future<void> _fetchRandomProduct() async {
    final url = Uri.parse('http://10.0.2.2:8000/api/products');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List data = jsonResponse['data'];

        if (data.isNotEmpty) {
          final randomIndex = Random().nextInt(data.length);
          setState(() {
            _randomProduct = Produk.fromJson(data[randomIndex]);
            _isLoadingProduct = false;
          });
        } else {
          setState(() {
            _isLoadingProduct = false;
          });
        }
      } else {
        setState(() {
          _isLoadingProduct = false;
        });
      }
    } catch (e) {
      print("Error: $e");
      setState(() {
        _isLoadingProduct = false;
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MarketplacePage()),
      ).then((_) {
        setState(() {
          _selectedIndex = 1;
        });
        _fetchRandomProduct();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildCustomAppBar(),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: Theme.of(context).colorScheme.primary,
        child: _buildHomePageBody(),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  PreferredSizeWidget _buildCustomAppBar() {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.primary,
      elevation: 0,
      leading: const Padding(
        padding: EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundColor: Colors.white24,
          child: Icon(Icons.person, color: Colors.white),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selamat datang di TerasDesa',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.white),
          onPressed: () async {
            final prefs = await SharedPreferences.getInstance();
            await prefs.clear();
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/login',
              (route) => false,
            );
          },
        ),
      ],
    );
  }

  Widget _buildHomePageBody() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      children: [
        Text(
          'Akses cepat',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildQuickAccessMenu(),
        const SizedBox(height: 24),

        Text(
          'Kabar Terbaru Desa',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        _buildFeedCard(
          imageUrl: 'https://placehold.co/600x400/png?text=Jembatan+Desa',
          category: 'PEMBANGUNAN',
          title: 'Pembenaran jembatan desa',
          subtitle: 'Progres saat ini: 15%...',
          categoryColor: Colors.blue[700]!,
        ),

        if (_isLoadingProduct)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          )
        else if (_randomProduct != null)
          _buildFeedCard(
            imageUrl: _randomProduct!.imageUrl,
            category: 'REKOMENDASI MARKETPLACE',
            title: _randomProduct!.name,
            subtitle: formatRupiah(_randomProduct!.price),
            categoryColor: Colors.orange[800]!,
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Detailproduk(produk: _randomProduct!),
                ),
              );
              if (result == true) {
                _fetchRandomProduct();
              }
            },
          )
        else
          _buildFeedCard(
            imageUrl:
                'https://placehold.co/600x400/grey/white?text=Belum+Ada+Produk',
            category: 'MARKETPLACE',
            title: 'Belum ada produk dijual',
            subtitle: 'Yuk mulai jualan!',
            categoryColor: Colors.grey,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MarketplacePage(),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildQuickAccessMenu() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildQuickAccessItem(
          icon: Icons.inventory_outlined,
          label: 'Aset Desa',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AsetPage()),
          ),
        ),
        _buildQuickAccessItem(
          icon: Icons.construction_outlined,
          label: 'Pembangunan',
          onTap: () {},
        ),
        _buildQuickAccessItem(
          icon: Icons.store_outlined,
          label: 'Marketplace',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MarketplacePage()),
            ).then((_) {
              setState(() {
                _selectedIndex = 1;
              });
              _fetchRandomProduct();
            });
          },
        ),
      ],
    );
  }

  Widget _buildQuickAccessItem({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
  }) {
    return Expanded(
      child: Card(
        elevation: 2.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 16.0,
              horizontal: 8.0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 32,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  textAlign: TextAlign.center,
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

  Widget _buildFeedCard({
    required String imageUrl,
    required String category,
    required String title,
    required String subtitle,
    required Color categoryColor,
    VoidCallback? onTap,
  }) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: Colors.white,
              height: 180,
              width: double.infinity,
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[200],
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.broken_image, size: 40, color: Colors.grey),
                      Text(
                        "Gagal memuat",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: categoryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[800],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      selectedItemColor: Theme.of(context).colorScheme.primary,
      unselectedItemColor: Colors.grey[600],
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.storefront_outlined),
          label: 'Market',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.home_filled),
          label: 'Beranda',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Akun',
        ),
      ],
    );
  }
}

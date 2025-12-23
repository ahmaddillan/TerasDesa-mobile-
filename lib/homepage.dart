import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
          _isLoadingProduct = false;
        }
      } else {
        _isLoadingProduct = false;
      }
    } catch (e) {
      _isLoadingProduct = false;
    }

    setState(() {});
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
      title: Text(
        'Selamat datang di TerasDesa',
        style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14),
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
        const Text(
          'Akses cepat',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildQuickAccessMenu(),
        const SizedBox(height: 24),

        const Text(
          'Kabar Terbaru Desa',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        _buildFeedCard(
          imageUrl: 'https://placehold.co/600x400/png?text=Jembatan+Desa',
          category: 'PEMBANGUNAN',
          title: 'Pembenaran jembatan desa',
          subtitle: 'Progres saat ini: 15%...',
          categoryColor: Colors.blue,
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
            categoryColor: Colors.orange,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => Detailproduk(produk: _randomProduct!),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildQuickAccessMenu() {
    return Row(
      children: [
        _quickMenu(
          icon: Icons.inventory_outlined,
          label: 'Aset Desa',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AsetPage()),
          ),
        ),
        _quickMenu(
          icon: Icons.store_outlined,
          label: 'Marketplace',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MarketplacePage()),
          ),
        ),
      ],
    );
  }

  Widget _quickMenu({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Card(
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Icon(icon, size: 32, color: Colors.green),
                const SizedBox(height: 8),
                Text(label),
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
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              imageUrl,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(12),
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
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

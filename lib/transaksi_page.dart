import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:terasdesa/detailtransaksi.dart';
import 'dart:convert';

import 'api_config.dart';
import 'checkout_page.dart';

class TransaksiPage extends StatefulWidget {
  const TransaksiPage({super.key});

  @override
  State<TransaksiPage> createState() => _TransaksiPageState();
}

class _TransaksiPageState extends State<TransaksiPage> {
  late Future<List<dynamic>> _futureTransaksi;

  @override
  void initState() {
    super.initState();
    _futureTransaksi = _fetchTransaksi();
  }

  // =========================
  // FETCH TRANSAKSI API
  // =========================
  Future<List<dynamic>> _fetchTransaksi() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/transaksi'),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Gagal mengambil transaksi');
    }
  }

  // =========================
  // UI
  // =========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),

      body: FutureBuilder<List<dynamic>>(
        future: _futureTransaksi,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Gagal memuat transaksi'));
          }

          final transaksiList = snapshot.data ?? [];

          if (transaksiList.isEmpty) {
            return const Center(child: Text('Belum ada transaksi'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _futureTransaksi = _fetchTransaksi();
              });
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildFilterRow(),
                const SizedBox(height: 16),
                _buildInfoBanner(),
                const SizedBox(height: 16),

                ...transaksiList.map(
                  (t) => _buildTransactionCard(
                    context: context,
                    transaksiId: t['id'],
                    date: t['created_at'],
                    total: t['total'],
                    status: t['status'],
                    items: t['items'] ?? [],
                  ),
                ),
              ],
            ),
          );
        },
      ),

      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // =========================
  // APP BAR
  // =========================
  AppBar _buildAppBar() {
    return AppBar(
      title: Container(
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: const TextField(
          decoration: InputDecoration(
            hintText: 'Cari transaksi',
            prefixIcon: Icon(Icons.search),
            border: InputBorder.none,
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CheckoutPage(),
                    ),
                  );

                  // AUTO REFRESH SETELAH CHECKOUT
                  if (result == true) {
                    setState(() {
                      _futureTransaksi = _fetchTransaksi();
                    });
                  }
                },
              ),
            ],
          ),
        ),
        IconButton(icon: const Icon(Icons.receipt_long), onPressed: () {}),
        const SizedBox(width: 8),
      ],
    );
  }

  // =========================
  // FILTER
  // =========================
  Widget _buildFilterRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _chip('Semua Status'),
          const SizedBox(width: 8),
          _chip('Semua Produk'),
          const SizedBox(width: 8),
          _chip('Semua'),
        ],
      ),
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Text(text),
          const SizedBox(width: 4),
          const Icon(Icons.keyboard_arrow_down, size: 16),
        ],
      ),
    );
  }

  // =========================
  // INFO BANNER
  // =========================
  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Keterlambatan Pick Up & Pengiriman',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SizedBox(height: 8),
          Text(
            'Proses pick up & pengiriman berpotensi terlambat sehubungan dengan tingginya antusiasme belanja.',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  // =========================
  // TRANSACTION CARD (API)
  // =========================
  Widget _buildTransactionCard({
    required BuildContext context,
    required int transaksiId,
    required String date,
    required dynamic total,
    required String status,
    required List items,
  }) {
    final parsedDate = DateTime.parse(date);

    final String productName = items.isNotEmpty
        ? items[0]['product_name']
        : 'Produk';

    final int moreItems = items.length > 1 ? items.length - 1 : 0;

    Color statusColor(String status) {
      switch (status.toLowerCase()) {
        case 'selesai':
        case 'success':
          return Colors.green;

        case 'pending':
        case 'menunggu':
          return Colors.orange;

        case 'batal':
        case 'cancel':
          return Colors.red;

        default:
          return Colors.grey;
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.shopping_bag),
                const SizedBox(width: 8),
                const Text('Belanja'),
                const Spacer(),
                Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    color: statusColor(status),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${parsedDate.day}/${parsedDate.month}/${parsedDate.year}',
              style: const TextStyle(fontSize: 12),
            ),
            const Divider(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  productName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                if (moreItems > 0)
                  Text(
                    '+$moreItems produk lainnya',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                const SizedBox(height: 6),
                Text(
                  'Total Belanja Rp ${double.parse(total.toString()).toStringAsFixed(0)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),

            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          DetailTransaksiPage(transaksiId: transaksiId),
                    ),
                  );
                },
                child: const Text('Beli Lagi'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================
  // BOTTOM NAV
  // =========================
  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: 3,
      selectedItemColor: const Color(0xFF00AA5B),
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
        BottomNavigationBarItem(icon: Icon(Icons.inventory), label: 'Aset'),
        BottomNavigationBarItem(
          icon: Icon(Icons.construction),
          label: 'Pembangunan',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Marketplace'),
      ],
    );
  }
}

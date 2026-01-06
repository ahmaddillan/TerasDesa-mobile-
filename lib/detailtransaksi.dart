import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'api_config.dart';

class DetailTransaksiPage extends StatefulWidget {
  final int transaksiId;

  const DetailTransaksiPage({
    super.key,
    required this.transaksiId,
  });

  @override
  State<DetailTransaksiPage> createState() => _DetailTransaksiPageState();
}

class _DetailTransaksiPageState extends State<DetailTransaksiPage> {
  late Future<Map<String, dynamic>> _futureDetail;

  @override
  void initState() {
    super.initState();
    _futureDetail = _fetchDetailTransaksi();
  }

  // =========================
  // FETCH DETAIL TRANSAKSI
  // =========================
  Future<Map<String, dynamic>> _fetchDetailTransaksi() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.get(
      Uri.parse(
        '${ApiConfig.baseUrl}/api/transaksi/${widget.transaksiId}',
      ),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Gagal memuat detail transaksi');
    }
  }

  // =========================
  // UI
  // =========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Transaksi'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _futureDetail,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Gagal memuat detail transaksi'));
          }

          final data = snapshot.data!;
          final List items = data['items'] ?? [];

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildHeader(data),
              const SizedBox(height: 16),
              _buildItemList(items),
              const SizedBox(height: 16),
              _buildSummary(data),
            ],
          );
        },
      ),
    );
  }

  // =========================
  // HEADER
  // =========================
  Widget _buildHeader(Map<String, dynamic> data) {
    final createdAt = DateTime.parse(data['created_at']);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.receipt_long),
                const SizedBox(width: 8),
                const Text(
                  'Status Transaksi',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  data['status'].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Tanggal: ${createdAt.day}/${createdAt.month}/${createdAt.year}',
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(
              'ID Transaksi: #${data['id']}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  // =========================
  // ITEM LIST
  // =========================
  Widget _buildItemList(List items) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Detail Produk',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            ...items.map((item) {
              final qty = item['qty'];
              final price = double.parse(item['price'].toString());

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['product_name'],
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$qty x Rp ${price.toStringAsFixed(0)}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'Rp ${(price * qty).toStringAsFixed(0)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  // =========================
  // SUMMARY
  // =========================
  Widget _buildSummary(Map<String, dynamic> data) {
    final total = double.parse(data['total'].toString());

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ringkasan Pembayaran',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _row('Total Belanja', total),
            const Divider(),
            _rowBold('Total Dibayar', total),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label),
          const Spacer(),
          Text('Rp ${value.toStringAsFixed(0)}'),
        ],
      ),
    );
  }

  Widget _rowBold(String label, double value) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const Spacer(),
        Text(
          'Rp ${value.toStringAsFixed(0)}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

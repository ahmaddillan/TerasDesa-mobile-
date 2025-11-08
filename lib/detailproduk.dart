// lib/detailproduk.dart

import 'package:flutter/material.dart';

class Detailproduk extends StatefulWidget {
  static const List<String> _thumbnails = [
    'https://kayu-seru.com/wp-content/uploads/2020/10/meja-belajar-kecil.jpg',
  ];

  const Detailproduk({super.key});

  @override
  State<Detailproduk> createState() => _DetailprodukState();
}

class _DetailprodukState extends State<Detailproduk> {
  final TextEditingController _notesController = TextEditingController();
  // Diubah ke string kosong agar pengecekan .isEmpty berfungsi
  String _catatan = '';

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Mengambil warna utama dari tema TerasDesa
    final Color primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: _buildAppBar(context),
      body: _buildBody(context, primaryColor),
      // Panggil method bottom bar
      bottomNavigationBar: _buildBottomNavBar(context, primaryColor),
    );
  }

  //widget builder appbar
  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.green[800]!,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back,
          color: Color.fromARGB(221, 255, 255, 255),
        ),
        onPressed: () {
          Navigator.pop(context); // Aksi untuk kembali
        },
      ),
      actions: [
        IconButton(
          icon: const Icon(
            Icons.search,
            color: Color.fromARGB(221, 255, 255, 255),
          ),
          onPressed: () {},
        ),
        _buildCartIcon(),
        IconButton(
          icon: const Icon(
            Icons.menu,
            color: Color.fromARGB(221, 255, 255, 255),
          ),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildCartIcon() {
    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          icon: const Icon(
            Icons.shopping_cart_outlined,
            color: Color.fromARGB(221, 255, 255, 255),
          ),
          onPressed: () {},
        ),
      ],
    );
  }

  // -widget builder body
  Widget _buildBody(BuildContext context, Color primaryColor) {
    return SingleChildScrollView(
      controller: ScrollController(),
      child: Container(
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageCarousel(),
            _buildOptions(context, primaryColor),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: _buildPriceSection(),
            ),
            _buildProductTitle(),

            // tombol berikan catatan diatas info toko
            Container(
              padding: const EdgeInsets.all(16.0),
              color: const Color(0xFFF8FFF2),
              margin: const EdgeInsets.only(top: 16.0), // Jarak dari judul
              child: _buildNotesButton(context),
            ),
            const Divider(thickness: 8, color: Color(0xFFF0F0F0)),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Area  catatan
                  _buildNoteDisplay(),

                  // Info Penjual
                  _buildSellerInfo(),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCarousel() {
    return Stack(
      children: [
        Image.network(
          'https://kayu-seru.com/wp-content/uploads/2020/10/meja-belajar-kecil.jpg',
          width: double.infinity,
          height: 300,
          fit: BoxFit.cover,
        ),
        Positioned(
          bottom: 16,
          left: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              '1/1',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSellerInfo() {
    // Dibungkus Column agar tombol bisa di bawah
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // logo toko
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.storefront,
                color: Colors.grey.shade700,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),

            // Info Toko
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Baris Nama & Verified
                  Row(
                    children: [
                      const Text(
                        'pengrajin kayu nagrak',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.check_circle,
                        color: Colors.purple.shade700,
                        size: 16,
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  // Baris Lokasi
                  Row(
                    children: [
                      Text(
                        'desa nagrak',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.info_outline,
                        color: Colors.grey.shade700,
                        size: 14,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Baris Rating
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      const Text(
                        '4.9',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        ' (123,8 rb)',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Baris Waktu Proses
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.schedule,
                        color: Colors.grey.shade700,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '± 1 jam pesanan diproses',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          // Bungkus dengan SizedBox agar bisa full width
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Following',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOptions(BuildContext context, Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '1 warna, 1 tinggi meja',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: Detailproduk._thumbnails.length,
              itemBuilder: (context, index) {
                return Container(
                  width: 60,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: index == 0 ? primaryColor : Colors.grey.shade300,
                      width: index == 0 ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      Detailproduk._thumbnails[index],
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rp292.000',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: const Color.fromARGB(255, 18, 18, 18),
          ),
        ),
        const SizedBox(height: 4),
      ],
    );
  }

  Widget _buildProductTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Expanded(
            child: Text(
              'Meja Lipat 100x50 Tinggi 75 cm Full Kayu Solid - Full Hitam, Tinggi 75 cm',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.favorite_border_outlined,
              color: Colors.grey.shade500,
              size: 28,
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  // widget builder bottom navbar
  Widget _buildBottomNavBar(BuildContext context, Color primaryColor) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        12 + MediaQuery.of(context).padding.bottom / 2,
      ),
      child: Row(
        children: [
          // 1. Tombol Chat
          IconButton(
            icon: Icon(
              Icons.forum_outlined,
              color: Colors.grey.shade700,
              size: 28,
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 10),

          Expanded(
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: const Text(
                '+ Keranjang',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Method untuk memunculkan Dialog
  Future<void> _showNotesDialog(BuildContext context) async {
    _notesController.text = _catatan;

    return showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Berikan Catatan'),
          content: TextField(
            controller: _notesController,
            autofocus: true,
            decoration: const InputDecoration(),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.pop(dialogContext);
              },
            ),
            TextButton(
              child: const Text('Simpan'),
              onPressed: () {
                setState(() {
                  _catatan = _notesController.text;
                });
                Navigator.pop(dialogContext);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildNoteDisplay() {
    if (_catatan.isEmpty) {
      return const SizedBox.shrink(); // Widget kosong
    }

    return Container(
      padding: const EdgeInsets.all(12.0),
      margin: const EdgeInsets.only(bottom: 16.0),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.notes_rounded, color: Colors.grey.shade700, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Catatan untuk penjual:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  _catatan, // Tampilkan catatan dari state
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesButton(BuildContext context) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;
    final bool hasNote = _catatan.isNotEmpty;

    return OutlinedButton(
      onPressed: () {
        _showNotesDialog(context); // Panggil dialog
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: BorderSide(color: primaryColor),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(vertical: 12),
        minimumSize: const Size(double.infinity, 36), // Full width
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              hasNote ? _catatan : 'berikan catatan',
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: hasNote ? Colors.black87 : primaryColor,
              ),
            ),
          ),
          if (hasNote) ...[
            const SizedBox(width: 8),
            Icon(Icons.edit, size: 16, color: primaryColor),
          ],
        ],
      ),
    );
  }
}

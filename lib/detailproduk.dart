import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'models/produk_model.dart';

class Detailproduk extends StatefulWidget {
  final Produk produk;

  const Detailproduk({super.key, required this.produk});

  @override
  State<Detailproduk> createState() => _DetailprodukState();
}

class _DetailprodukState extends State<Detailproduk> {
  final TextEditingController _notesController = TextEditingController();
  String _catatan = '';
  bool _isDeleting = false;

  String formatRupiah(int price) {
    return NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(price);
  }

  //hapus produk
  Future<void> _deleteProduct() async {
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Produk"),
        content: const Text("Yakin ingin menghapus produk ini?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isDeleting = true;
    });

    final url = Uri.parse(
      'http://10.0.2.2:8000/api/products/${widget.produk.id}',
    );

    try {
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Produk berhasil dihapus")),
          );
          Navigator.pop(context, true);
        }
      } else {
        throw Exception("Gagal menghapus: ${response.statusCode}");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Colors.green[800]!;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Detail Produk",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: _isDeleting ? null : _deleteProduct,
            icon: _isDeleting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.delete_outline, color: Colors.white),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //Gambar Produk
            Container(
              height: 300,
              width: double.infinity,
              color: Colors.white,
              child: Image.network(
                widget.produk.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (ctx, error, stackTrace) => Container(
                  color: Colors.grey[200],
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.broken_image, size: 50, color: Colors.grey),
                      Text(
                        "Gagal memuat gambar",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formatRupiah(widget.produk.price),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.produk.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),

                  //Info Penjual
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(child: Icon(Icons.store)),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Penjual: ${widget.produk.sellerName}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "Lokasi: ${widget.produk.sellerLocation}",
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const Divider(height: 30),
                  const Text(
                    "Deskripsi",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.produk.description,
                    style: TextStyle(color: Colors.grey[800], height: 1.5),
                  ),

                  const SizedBox(height: 20),

                  //Catatan Pesanan
                  OutlinedButton.icon(
                    onPressed: () => _showNotesDialog(context),
                    icon: const Icon(Icons.edit, size: 16),
                    label: Text(
                      _catatan.isEmpty
                          ? "Tambah Catatan Pesanan"
                          : "Ubah Catatan",
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primaryColor,
                    ),
                  ),
                  if (_catatan.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        "Catatan: $_catatan",
                        style: const TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ],
        ),
      ),

      //Bottom Bar Beli
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.chat_bubble_outline, color: primaryColor),
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.shopping_cart_outlined, color: primaryColor),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Fitur Checkout akan segera hadir!"),
                    ),
                  );
                },
                child: const Text(
                  "Beli Sekarang",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showNotesDialog(BuildContext context) async {
    _notesController.text = _catatan;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Catatan"),
        content: TextField(
          controller: _notesController,
          decoration: const InputDecoration(
            hintText: "Contoh: Bungkus warna merah ya",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _catatan = _notesController.text;
              });
              Navigator.pop(context);
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }
}

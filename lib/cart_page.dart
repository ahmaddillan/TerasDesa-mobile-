import 'package:flutter/material.dart';
import 'package:terasdesa/checkout_page.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Keranjang'),
        actions: const [Icon(Icons.favorite_border)],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: const [
                CartItem(
                  shopName: 'Toko Official',
                  productName: 'PressPlay Canopy PBT Keycaps',
                  price: 'Rp136.000',
                  oldPrice: 'Rp160.000',
                  discount: '15%',
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Checkbox(value: false, onChanged: (_) {}),
                const Text('Semua'),
                const Spacer(),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CheckoutPage()),
                    );
                  },
                  child: const Text('Checkout'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CartItem extends StatelessWidget {
  final String shopName;
  final String productName;
  final String price;
  final String? oldPrice;
  final String? discount;

  const CartItem({
    super.key,
    required this.shopName,
    required this.productName,
    required this.price,
    this.oldPrice,
    this.discount,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Checkbox(value: false, onChanged: (_) {}),
                Text(
                  shopName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(width: 60, height: 60, color: Colors.grey),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(productName),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            price,
                            style: const TextStyle(color: Colors.red),
                          ),
                          if (oldPrice != null)
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Text(
                                oldPrice!,
                                style: const TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ),
                          if (discount != null)
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Text(
                                discount!,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

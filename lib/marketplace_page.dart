import 'package:flutter/material.dart';

class Marketplace extends StatefulWidget {
  const Marketplace({super.key});

  @override
  State<Marketplace> createState() => _MarketplaceState();
}

class _MarketplaceState extends State<Marketplace> {
  int selectedIndex = 1;
  TextEditingController searchController = TextEditingController();

  final List<Map<String, String>> allProducts = [
    {
      "name": "Meja Lesehan Kayu Jati",
      "price": "Rp69.300",
      "rating": "4.6",
      "sold": "1rb+ terjual",
      "location": "Kota Jakarta Barat",
      "image":
          "https://i0.wp.com/kayu-seru.com/wp-content/uploads/2020/10/Meja-Belajar-Kayu.jpg?fit=600%2C600&ssl=1",
    },
    {
      "name": "Sabun Lifebuoy",
      "price": "Rp120.000",
      "rating": "4.8",
      "sold": "500+ terjual",
      "location": "Kota Bandung",
      "image":
          "https://images.tokopedia.net/img/cache/700/product-1/2020/8/25/13044588/13044588_f6f93ab4-0214-4df5-a7d8-6bb6e3ff54e9_700_700.jpg",
    },
    {
      "name": "Beras Sedap Wangi",
      "price": "Rp89.000",
      "rating": "4.9",
      "sold": "2rb+ terjual",
      "location": "Kota Surabaya",
      "image":
          "https://images.tokopedia.net/img/cache/700/product-1/2020/9/22/8872531/8872531_a8e9b54c-357b-4c9f-b217-8e01f7f1d292_700_700.jpg",
    },
    {
      "name": "Ember Gagang",
      "price": "Rp25.000",
      "rating": "4.4",
      "sold": "800+ terjual",
      "location": "Kota Medan",
      "image":
          "https://images.tokopedia.net/img/cache/700/product-1/2021/6/3/8872531/8872531_b4d5f60a-64b1-49f2-9f8e-ef2b1d123abc_700_700.jpg",
    },
    {
      "name": "Sapu Nilon",
      "price": "Rp32.000",
      "rating": "4.6",
      "sold": "1rb+ terjual",
      "location": "Kota Jakarta Barat",
      "image":
          "https://images.tokopedia.net/img/cache/700/product-1/2021/5/18/13044588/13044588_27dffac4-6f13-4c4d-82b7-662b4012d27e_700_700.jpg",
    },
    {
      "name": "Sirup Marjan Cocopandan",
      "price": "Rp45.000",
      "rating": "4.8",
      "sold": "900+ terjual",
      "location": "Kota Bandung",
      "image":
          "https://images.tokopedia.net/img/cache/700/product-1/2021/3/11/12345678/12345678_ba3a43f7-6cb3-4e8f-a2b9-cdc154e44433_700_700.jpg",
    },
  ];

  List<Map<String, String>> displayedProducts = [];

  @override
  void initState() {
    super.initState();
    displayedProducts = List.from(allProducts);
  }

  void searchProduct(String query) {
    final results = allProducts.where((product) {
      final name = product["name"]!.toLowerCase();
      final input = query.toLowerCase();
      return name.contains(input);
    }).toList();

    setState(() {
      displayedProducts = results;
    });
  }

  void onNavTap(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      body: SafeArea(
        child: Column(
          children: [
            // NAVBAR
            Container(
              color: Colors.green[700],
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const CircleAvatar(
                    radius: 20,
                    backgroundColor: Color(0xFFBEE5AE),
                    backgroundImage: NetworkImage(
                      'https://cdn-icons-png.flaticon.com/512/3135/3135715.png',
                    ),
                  ),
                  const Text(
                    'Marketplace',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.shopping_basket_outlined,
                      size: 28,
                      color: Colors.white,
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
            ),

            // SEARCH BAR
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                controller: searchController,
                onChanged: searchProduct,
                decoration: InputDecoration(
                  hintText: 'Cari nama barang...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 20,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // PRODUK GRID
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: GridView.builder(
                  itemCount: displayedProducts.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.68,
                  ),
                  itemBuilder: (context, index) {
                    final product = displayedProducts[index];
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(14),
                            ),
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: Image.network(
                                product["image"]!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Center(
                                      child: Icon(
                                        Icons.broken_image,
                                        size: 50,
                                        color: Colors.grey,
                                      ),
                                    ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                              vertical: 4,
                            ),
                            child: Text(
                              product["name"]!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                            ),
                            child: Text(
                              product["price"]!,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 30),
                                side: const BorderSide(
                                  color: Colors.green,
                                  width: 1.3,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () {},
                              child: const Text(
                                "+ Keranjang",
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),

      // BOTTOM NAVIGATION
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              onPressed: () => onNavTap(0),
              icon: Icon(
                Icons.storefront_outlined,
                size: 28,
                color: selectedIndex == 0 ? Colors.black : Colors.black54,
              ),
            ),
            IconButton(
              onPressed: () => onNavTap(1),
              icon: Icon(
                Icons.home_filled,
                size: 28,
                color: selectedIndex == 1 ? Colors.black : Colors.black54,
              ),
            ),
            IconButton(
              onPressed: () => onNavTap(2),
              icon: Icon(
                Icons.person_outline,
                size: 28,
                color: selectedIndex == 2 ? Colors.black : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

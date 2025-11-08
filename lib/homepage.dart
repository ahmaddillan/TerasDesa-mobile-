import 'package:flutter/material.dart';
import 'package:terasdesa/detailproduk.dart';
import 'package:terasdesa/login_page.dart';
import 'package:terasdesa/aset_page.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  // Melacak tab yang sedang aktif di Bottom Navigation Bar
  int _selectedIndex = 1;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    //untuk menambahkan logika navigasi
    // Contoh: if (index == 1) Navigator.push(...)
  }

  @override
  Widget build(BuildContext context) {
    // Menggunakan Scaffold sebagai kerangka utama halaman
    return Scaffold(
      appBar: _buildCustomAppBar(),
      body: _buildHomePageBody(), // Menampilkan body khusus untuk tab 'Beranda'
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  /// widget appbar kustom
  PreferredSizeWidget _buildCustomAppBar() {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.primary,
      elevation: 0,
      leading: const Padding(
        padding: EdgeInsets.all(8.0),
        child: CircleAvatar(
          // Ganti dengan URL gambar profil pengguna
          //backgroundImage:,
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
        // Tombol notifikasi
        IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            );
          },
        ),
      ],
    );
  }

  /// widget body homepage
  Widget _buildHomePageBody() {
    // Menggunakan ListView agar konten bisa di-scroll
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Menu Akses Cepat
        Text(
          'Akses cepat',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildQuickAccessMenu(), // Memanggil helper widget menu
        const SizedBox(height: 24),

        //  Feed Kabar Terbaru
        Text(
          'Kabar Terbaru Desa',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        // Kartu Feed 1
        _buildFeedCard(
          imageUrl: '',
          category: 'PEMBANGUNAN',
          title: 'pembenaran jembatan desa',
          subtitle: 'Progres saat ini: 15%. Diperkirakan selesai...',
          categoryColor: Colors.blue[700]!,
        ),

        // Kartu Feed 2
        _buildFeedCard(
          imageUrl:
              'https://kayu-seru.com/wp-content/uploads/2020/10/meja-belajar-kecil.jpg',
          category: 'MARKETPLACE',
          title: 'Meja lesehan kayu',
          subtitle: 'Rp 130.000',
          categoryColor: Colors.orange[800]!,

          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Detailproduk()),
            );
          },
        ),
      ],
    );
  }

  /// row menu akses cepat
  Widget _buildQuickAccessMenu() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildQuickAccessItem(
          icon: Icons.inventory_outlined,
          label: 'Aset Desa',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AsetPage()),
            );
          },
        ),
        _buildQuickAccessItem(
          icon: Icons.construction_outlined,
          label: 'Pembangunan',
          onTap: () {},
        ),
        _buildQuickAccessItem(
          icon: Icons.store_outlined,
          label: 'Marketplace',
          onTap: () {},
        ),
      ],
    );
  }

  /// item menu akses cepat
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

  /// kartu feed
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
            // item 1 :gambar
            Container(
              color: Colors.white,
              height: 180,
              width: double.infinity,
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(
                      Icons.broken_image,
                      size: 40,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            ),
            // item 2 : teks
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
                      letterSpacing: 0.5,
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// bottom navbar
  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed, // menampilkan fix item 4 maksimal
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

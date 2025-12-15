class Produk {
  final int id;
  final String name;
  final int price;
  final String description;
  final String imageUrl;
  final String sellerName;
  final String sellerLocation;
  final double rating;
  final int soldCount;

  Produk({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.imageUrl,
    required this.sellerName,
    required this.sellerLocation,
    required this.rating,
    required this.soldCount,
  });
  factory Produk.fromJson(Map<String, dynamic> json) {
    return Produk(
      id: json['id'] ?? 0,

      name: json['name'] ?? 'Tanpa Nama',

      price: json['price'] != null
          ? int.tryParse(json['price'].toString()) ?? 0
          : 0,

      description: json['description'] ?? '-',
      imageUrl: json['image_url'] ?? '',

      sellerName: json['seller_name'] ?? 'Warga Desa',
      sellerLocation: json['seller_location'] ?? '-',

      rating: json['rating'] != null
          ? double.tryParse(json['rating'].toString()) ?? 0.0
          : 0.0,

      soldCount: json['sold_count'] != null
          ? int.tryParse(json['sold_count'].toString()) ?? 0
          : 0,
    );
  }
}

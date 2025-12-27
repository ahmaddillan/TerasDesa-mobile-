class ProdukModel {
  final int id;
  final String name;
  final String description;
  final double price;
  final String? imageUrl;
  final int? userId;
  final int stock;

  ProdukModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.imageUrl,
    this.userId,
    required this.stock,
  });

  factory ProdukModel.fromJson(Map<String, dynamic> json) {
    return ProdukModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: json['price'] != null
          ? double.parse(json['price'].toString())
          : 0.0,
      // Backend menggunakan kolom image_url
      imageUrl: json['image_url'] ?? json['imageUrl'],
      userId: json['user_id'],
      stock: json['stock'] ?? 0,
    );
  }
}

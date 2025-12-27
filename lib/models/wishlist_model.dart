import 'produk_model.dart';

class WishlistModel {
  final int wishlistId; // Diambil dari w.id as wishlist_id di query SQL Anda
  final ProdukModel produk;

  WishlistModel({required this.wishlistId, required this.produk});

  factory WishlistModel.fromJson(Map<String, dynamic> json) {
    return WishlistModel(
      // wishlistId mengambil alias 'wishlist_id' dari query SQL backend Anda
      wishlistId: json['wishlist_id'] ?? 0,
      // Objek produk dibuat dari json yang sama karena datanya flat (mendatar)
      produk: ProdukModel.fromJson(json),
    );
  }
}

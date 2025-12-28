class AsetModel {
  final int? id;
  final String nama;
  final String lokasi;
  final String status;
  final String? gambarUrl;
  final String deskripsi;

  AsetModel({
    this.id,
    required this.nama,
    required this.lokasi,
    required this.status,
    this.gambarUrl,
    required this.deskripsi,
  });

  factory AsetModel.fromJson(Map<String, dynamic> json) {
    return AsetModel(
      id: json['id'],
      nama: json['nama'],
      lokasi: json['lokasi'],
      status: json['status'],
      gambarUrl: json['gambar_url'],
      deskripsi: json['deskripsi'],
    );
  }
}

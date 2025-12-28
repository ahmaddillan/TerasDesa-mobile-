class TransaksiModel {
  final int id;
  final double total;
  final String status;
  final DateTime createdAt;

  TransaksiModel({
    required this.id,
    required this.total,
    required this.status,
    required this.createdAt,
  });

  factory TransaksiModel.fromJson(Map<String, dynamic> json) {
    return TransaksiModel(
      id: json['id'],
      total: double.parse(json['total'].toString()),
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

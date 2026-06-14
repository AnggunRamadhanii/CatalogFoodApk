class OrderModel {
  final String id;
  final Map<String, dynamic> items;
  final int totalHarga;
  final DateTime createdAt;
  String status;

  OrderModel({
    required this.id,
    required this.items,
    required this.totalHarga,
    required this.createdAt,
    required this.status,
  });

  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'items': items, 
      'total_harga': totalHarga,
      'status': status,
      
    };
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'],
      items: Map<String, dynamic>.from(json['items']),
      totalHarga: json['total_harga'],
      createdAt: DateTime.parse(json['created_at']),
      status: json['status'],
    );
  }
}
class Item {
  final String id;
  final String name;
  final double price;
  final String? barcode;
  final DateTime createdAt;

  Item({
    required this.id,
    required this.name,
    required this.price,
    this.barcode,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'barcode': barcode,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      barcode: json['barcode'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  @override
  String toString() {
    return 'Item(id: $id, name: $name, price: $price, barcode: $barcode)';
  }
}

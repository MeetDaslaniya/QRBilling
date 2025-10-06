class Item {
  final String id;
  final String name;
  final double price;
  final String barcode;
  final DateTime date;

  Item({
    required this.id,
    required this.name,
    required this.price,
    required this.barcode,
    DateTime? date,
  }) : date = date ?? DateTime.now();

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      barcode: json['barcode'] as String,
      date: DateTime.parse(json['date'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'barcode': barcode,
      'date': date.toIso8601String(),
    };
  }

  Item copyWith({
    String? id,
    String? name,
    double? price,
    String? barcode,
    DateTime? date,
  }) {
    return Item(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      barcode: barcode ?? this.barcode,
      date: date ?? this.date,
    );
  }

  @override
  String toString() {
    return 'Item(id: $id, name: $name, price: $price, barcode: $barcode, date: $date)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Item &&
        other.id == id &&
        other.name == name &&
        other.price == price &&
        other.barcode == barcode &&
        other.date == date;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        price.hashCode ^
        barcode.hashCode ^
        date.hashCode;
  }
}

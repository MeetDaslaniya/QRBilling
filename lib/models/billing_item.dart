import 'item.dart';

class BillingItem {
  final Item item;
  final int quantity;

  BillingItem({
    required this.item,
    this.quantity = 1,
  });

  factory BillingItem.fromItem(Item item, {int quantity = 1}) {
    return BillingItem(item: item, quantity: quantity);
  }

  factory BillingItem.fromJson(Map<String, dynamic> json) {
    return BillingItem(
      item: Item.fromJson(json['item'] as Map<String, dynamic>),
      quantity: json['quantity'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'item': item.toJson(),
      'quantity': quantity,
    };
  }

  BillingItem copyWith({
    Item? item,
    int? quantity,
  }) {
    return BillingItem(
      item: item ?? this.item,
      quantity: quantity ?? this.quantity,
    );
  }

  double get totalPrice => item.price * quantity;

  // Getters for easy access to item properties
  String get id => item.id;
  String get name => item.name;
  double get price => item.price;
  String get barcode => item.barcode;
  DateTime get date => item.date;

  @override
  String toString() {
    return 'BillingItem(item: $item, quantity: $quantity)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BillingItem &&
        other.item == item &&
        other.quantity == quantity;
  }

  @override
  int get hashCode {
    return item.hashCode ^ quantity.hashCode;
  }
}

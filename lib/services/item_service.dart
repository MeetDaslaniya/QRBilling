import 'package:hive_flutter/hive_flutter.dart';
import '../models/item.dart';

class ItemService {
  static ItemService? _instance;
  static ItemService get instance => _instance ??= ItemService._();

  ItemService._();

  static const String _boxName = 'itemsBox';
  late Box<Item> _box;

  Future<void> init() async {
    _box = await Hive.openBox<Item>(_boxName);
  }

  List<Item> get items => _box.values.toList();

  Future<void> addItem(Item item) async {
    await _box.put(item.id, item);
  }

  Future<void> deleteItem(String itemId) async {
    await _box.delete(itemId);
  }

  Item getItemByBarcode(String barcode) {
    try {
      return _box.values.firstWhere(
        (item) => item.barcode == barcode,
      );
    } catch (e) {
      throw StateError('No item found with barcode: $barcode');
    }
  }

  bool hasItemWithBarcode(String barcode) {
    return _box.values.any((item) => item.barcode == barcode);
  }

  Future<void> clearAllItems() async {
    await _box.clear();
  }

  void close() {
    _box.close();
  }
}

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/item.dart';

class ItemService {
  static ItemService? _instance;
  static ItemService get instance => _instance ??= ItemService._();

  ItemService._();

  List<Item> _items = [];

  List<Item> get items => List.unmodifiable(_items);

  Future<void> loadItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final itemsJson = prefs.getStringList('billing_items') ?? [];
      _items =
          itemsJson.map((json) => Item.fromJson(jsonDecode(json))).toList();
    } catch (e) {
      _items = [];
    }
  }

  Future<void> saveItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final itemsJson =
          _items.map((item) => jsonEncode(item.toJson())).toList();
      await prefs.setStringList('billing_items', itemsJson);
    } catch (e) {
      throw Exception('Failed to save items: $e');
    }
  }

  Future<void> addItem(Item item) async {
    _items.add(item);
    await saveItems();
  }

  Future<void> deleteItem(String itemId) async {
    _items.removeWhere((item) => item.id == itemId);
    await saveItems();
  }

  double getTotalAmount() {
    return _items.fold(0.0, (sum, item) => sum + item.price);
  }
}

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/item.dart';
import '../config/supabase_config.dart';

class ItemService {
  static ItemService? _instance;
  static ItemService get instance => _instance ??= ItemService._();

  ItemService._();

  static const String _tableName = 'products';
  SupabaseClient get _client => SupabaseConfig.client;

  Future<void> init() async {
    // No initialization needed for Supabase
  }

  Future<List<Item>> get items async {
    try {
      final response = await _client
          .from(_tableName)
          .select()
          .order('date', ascending: false);

      return (response as List)
          .map((json) => Item.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch items: $e');
    }
  }

  Future<void> addItem(Item item) async {
    try {
      await _client.from(_tableName).insert(item.toJson());
    } catch (e) {
      throw Exception('Failed to add item: $e');
    }
  }

  Future<void> updateItem(Item item) async {
    try {
      await _client.from(_tableName).update(item.toJson()).eq('id', item.id);
    } catch (e) {
      throw Exception('Failed to update item: $e');
    }
  }

  Future<void> deleteItem(String itemId) async {
    try {
      await _client.from(_tableName).delete().eq('id', itemId);
    } catch (e) {
      throw Exception('Failed to delete item: $e');
    }
  }

  Future<Item> getItemByBarcode(String barcode) async {
    try {
      final response = await _client
          .from(_tableName)
          .select()
          .eq('barcode', barcode)
          .single();

      return Item.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw StateError('No item found with barcode: $barcode');
    }
  }

  Future<bool> hasItemWithBarcode(String barcode) async {
    try {
      final response = await _client
          .from(_tableName)
          .select('id')
          .eq('barcode', barcode)
          .maybeSingle();

      return response != null;
    } catch (e) {
      return false;
    }
  }

  Future<void> clearAllItems() async {
    try {
      await _client.from(_tableName).delete().neq('id', '');
    } catch (e) {
      throw Exception('Failed to clear all items: $e');
    }
  }

  // Real-time subscription for products
  RealtimeChannel subscribeToProducts(Function(List<Item>) onData) {
    return _client
        .channel('products_channel')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: _tableName,
          callback: (payload) async {
            // Fetch updated data when changes occur
            final updatedItems = await items;
            onData(updatedItems);
          },
        )
        .subscribe();
  }

  void close() {
    // No close needed for Supabase
  }
}

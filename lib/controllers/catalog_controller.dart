import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/item.dart';
import '../services/item_service.dart';

class CatalogController extends GetxController {
  final ItemService _itemService = ItemService.instance;

  // Observable variables
  final RxList<Item> catalogItems = <Item>[].obs;
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  RealtimeChannel? _realtimeChannel;

  @override
  void onInit() {
    super.onInit();
    _loadCatalogItems();
    _setupRealtimeSubscription();
  }

  @override
  void onClose() {
    _realtimeChannel?.unsubscribe();
    super.onClose();
  }

  void _setupRealtimeSubscription() {
    _realtimeChannel = _itemService.subscribeToProducts((items) {
      catalogItems.value = items;
      isLoading.value = false;
      errorMessage.value = '';
    });
  }

  Future<void> loadCatalogItems() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final items = await _itemService.items;
      catalogItems.value = items;
      isLoading.value = false;
    } catch (e) {
      errorMessage.value = 'Failed to load catalog: $e';
      isLoading.value = false;
    }
  }

  Future<void> addItem(Item item) async {
    try {
      await _itemService.addItem(item);
      // Real-time subscription will automatically update the list
    } catch (e) {
      errorMessage.value = 'Failed to add item: $e';
    }
  }

  Future<void> updateItem(Item item) async {
    try {
      await _itemService.updateItem(item);
      // Real-time subscription will automatically update the list
    } catch (e) {
      errorMessage.value = 'Failed to update item: $e';
    }
  }

  Future<void> deleteItem(String itemId) async {
    try {
      await _itemService.deleteItem(itemId);
      // Real-time subscription will automatically update the list
    } catch (e) {
      errorMessage.value = 'Failed to delete item: $e';
    }
  }

  Future<bool> hasItemWithBarcode(String barcode) async {
    try {
      return await _itemService.hasItemWithBarcode(barcode);
    } catch (e) {
      errorMessage.value = 'Failed to check barcode: $e';
      return false;
    }
  }

  Future<Item> getItemByBarcode(String barcode) async {
    try {
      return await _itemService.getItemByBarcode(barcode);
    } catch (e) {
      errorMessage.value = 'Failed to get item: $e';
      rethrow;
    }
  }

  void clearError() {
    errorMessage.value = '';
  }

  // Private method for initial load
  Future<void> _loadCatalogItems() async {
    await loadCatalogItems();
  }
}

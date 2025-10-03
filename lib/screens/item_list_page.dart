import 'package:flutter/material.dart';
import '../models/item.dart';
import '../services/item_service.dart';
import '../services/session_service.dart';

class ItemListPage extends StatefulWidget {
  const ItemListPage({super.key});

  @override
  State<ItemListPage> createState() => _ItemListPageState();
}

class _ItemListPageState extends State<ItemListPage> {
  final ItemService _itemService = ItemService.instance;
  final SessionService _sessionService = SessionService.instance;
  List<Item> _billingItems = []; // Items in current bill
  double _totalAmount = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  Future<void> _loadSession() async {
    setState(() => _isLoading = true);
    try {
      final sessionItems = await _sessionService.loadSession();
      setState(() {
        _billingItems = sessionItems;
        _isLoading = false;
      });
      _updateTotal();

      // Show subtle message if session was restored
      if (sessionItems.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Restored ${sessionItems.length} items from previous session'),
            backgroundColor: Colors.blue[600],
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      // Silent fail for session loading - start with empty bill
      print('Session load failed: $e');
    }
  }

  Future<void> _saveSession() async {
    try {
      await _sessionService.saveSession(_billingItems);
    } catch (e) {
      // Silent fail for session saving - don't show error to user
      // Session saving is a background operation and shouldn't interrupt user flow
      print('Session save failed: $e');
    }
  }

  void _updateTotal() {
    setState(() {
      _totalAmount = _billingItems.fold(0.0, (sum, item) => sum + item.price);
    });
    _saveSession(); // Auto-save session when total updates
  }

  Future<void> _addScannedItem(String scannedBarcode) async {
    try {
      // Check if product exists in catalog
      if (!_itemService.hasItemWithBarcode(scannedBarcode)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Product not found in catalog. Please add it first.'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Get product from catalog
      final catalogItem = _itemService.getItemByBarcode(scannedBarcode);

      // Add to billing items
      setState(() {
        _billingItems.add(catalogItem);
        _updateTotal();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Added: ${catalogItem.name} - ₹${catalogItem.price.toStringAsFixed(2)}'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add item: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _removeItem(int index) {
    setState(() {
      _billingItems.removeAt(index);
      _updateTotal();
    });
  }

  void _clearBill() {
    setState(() {
      _billingItems.clear();
      _updateTotal();
    });
    // Silent session clear - don't show error to user
    _sessionService.clearSession().catchError((e) {
      print('Session clear failed: $e');
    });
  }

  void _showNewProductDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Product'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Item Name',
                hintText: 'Enter item name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Price',
                hintText: '0.00',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.currency_rupee),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  priceController.text.isNotEmpty) {
                final price = double.tryParse(priceController.text.trim());
                if (price != null && price > 0) {
                  // Create a temporary item for billing (no barcode)
                  final tempItem = Item(
                    id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
                    name: nameController.text.trim(),
                    price: price,
                    barcode: '', // Empty barcode for direct billing items
                  );

                  setState(() {
                    _billingItems.add(tempItem);
                    _updateTotal();
                  });

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Added: ${tempItem.name} - ₹${tempItem.price.toStringAsFixed(2)}'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a valid price'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please fill all fields'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Add to Bill'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back, size: 24),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 16),
                        const Text(
                          'Billing',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          // Navigate to QR Scanner
                          final result =
                              await Navigator.pushNamed(context, '/qr-scanner');
                          if (result != null) {
                            await _addScannedItem(result as String);
                          }
                        },
                        icon: const Icon(Icons.qr_code_scanner, size: 20),
                        label: const Text(
                          'SCAN BARCODE',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'BILL ITEMS',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        if (_billingItems.isNotEmpty)
                          TextButton(
                            onPressed: _clearBill,
                            child: Text(
                              'Clear All',
                              style: TextStyle(
                                color: Colors.red[600],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : _billingItems.isEmpty
                              ? const Center(
                                  child: Text(
                                    'No items in bill yet.\nTap "SCAN BARCODE" to add items.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: _billingItems.length,
                                  itemBuilder: (context, index) {
                                    final item = _billingItems[index];
                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 12),
                                      child: Card(
                                        elevation: 2,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      item.name,
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black87,
                                                      ),
                                                    ),
                                                    if (item.barcode.isNotEmpty)
                                                      Text(
                                                        'Barcode: ${item.barcode}',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color:
                                                              Colors.grey[600],
                                                        ),
                                                      )
                                                    else
                                                      Text(
                                                        'Direct Entry',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color:
                                                              Colors.blue[600],
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  Text(
                                                    '₹${item.price.toStringAsFixed(2)}',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.grey[700],
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  IconButton(
                                                    onPressed: () =>
                                                        _removeItem(index),
                                                    icon: Icon(
                                                      Icons
                                                          .remove_circle_outline,
                                                      color: Colors.red[600],
                                                      size: 20,
                                                    ),
                                                    padding: EdgeInsets.zero,
                                                    constraints:
                                                        const BoxConstraints(),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green[200]!),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Amount',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            '₹${_totalAmount.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _showNewProductDialog,
                            icon:
                                const Icon(Icons.add_circle_outline, size: 20),
                            label: const Text(
                              'New Product',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[600],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _billingItems.isEmpty
                                ? null
                                : () async {
                                    // Generate receipt functionality
                                    try {
                                      await _sessionService.clearSession();
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              'Receipt generated for ₹${_totalAmount.toStringAsFixed(2)}'),
                                          backgroundColor: Colors.green[600],
                                        ),
                                      );
                                      // Clear the bill after generating receipt
                                      setState(() {
                                        _billingItems.clear();
                                        _updateTotal();
                                      });
                                    } catch (e) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              'Failed to generate receipt: $e'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[600],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            child: const Text(
                              'Generate Receipt',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../models/item.dart';
import '../services/item_service.dart';

class ItemEntryPage extends StatefulWidget {
  const ItemEntryPage({super.key});

  @override
  State<ItemEntryPage> createState() => _ItemEntryPageState();
}

class _ItemEntryPageState extends State<ItemEntryPage> {
  final ItemService _itemService = ItemService.instance;
  final TextEditingController _barcodeController = TextEditingController();
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  @override
  void dispose() {
    _barcodeController.dispose();
    _itemNameController.dispose();
    _priceController.dispose();
    super.dispose();
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
                          'Product Entry',
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
                            // Auto-fill the barcode field with scanned data
                            _barcodeController.text = result as String;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Scanned: $result'),
                                backgroundColor: Colors.green,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
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
                    TextField(
                      controller: _barcodeController,
                      decoration: InputDecoration(
                        labelText: 'Barcode',
                        hintText: 'Enter or scan barcode',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: Colors.green[600]!, width: 2),
                        ),
                        prefixIcon:
                            Icon(Icons.qr_code, color: Colors.grey[600]),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _itemNameController,
                      decoration: InputDecoration(
                        labelText: 'Item Name',
                        hintText: 'Enter item name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: Colors.green[600]!, width: 2),
                        ),
                        prefixIcon:
                            Icon(Icons.shopping_cart, color: Colors.grey[600]),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Price',
                        hintText: '0.00',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: Colors.green[600]!, width: 2),
                        ),
                        prefixIcon:
                            Icon(Icons.currency_rupee, color: Colors.grey[600]),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          // Submit functionality
                          if (_barcodeController.text.isNotEmpty &&
                              _itemNameController.text.isNotEmpty &&
                              _priceController.text.isNotEmpty) {
                            try {
                              final price =
                                  double.tryParse(_priceController.text.trim());
                              if (price == null || price <= 0) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please enter a valid price'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }

                              // Check if barcode already exists
                              if (_itemService.hasItemWithBarcode(
                                  _barcodeController.text.trim())) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Product with this barcode already exists'),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                                return;
                              }

                              final item = Item(
                                id: DateTime.now()
                                    .millisecondsSinceEpoch
                                    .toString(),
                                name: _itemNameController.text.trim(),
                                price: price,
                                barcode: _barcodeController.text.trim(),
                              );

                              await _itemService.addItem(item);

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Product Added: ${_itemNameController.text} - ₹${_priceController.text}',
                                  ),
                                  backgroundColor: Colors.green[600],
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              );
                              _barcodeController.clear();
                              _itemNameController.clear();
                              _priceController.clear();
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to add product: $e'),
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
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: const Text(
                          'Add Product',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
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

import 'package:flutter/material.dart';
import '../models/item.dart';
import '../services/item_service.dart';
import '../theme/app_theme.dart';

class ItemEntryPage extends StatefulWidget {
  const ItemEntryPage({super.key});

  @override
  State<ItemEntryPage> createState() => _ItemEntryPageState();
}

class _ItemEntryPageState extends State<ItemEntryPage> {
  final ItemService _itemService = ItemService.instance;
  final TextEditingController _barcodeController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _barcodeController.dispose();
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryColor,
              AppTheme.backgroundColor,
            ],
            stops: [0.0, 0.3],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header Section
              Container(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        padding: const EdgeInsets.all(8),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Add Product',
                            style: Theme.of(context)
                                .textTheme
                                .headlineLarge
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            'Add new product to catalog',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Colors.white.withOpacity(0.8),
                                ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        onPressed: () async {
                          final result =
                              await Navigator.pushNamed(context, '/qr-scanner');
                          if (result != null) {
                            setState(() {
                              _barcodeController.text = result as String;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Barcode scanned: $result'),
                                backgroundColor: AppTheme.successColor,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.qr_code_scanner,
                            color: Colors.white),
                        padding: const EdgeInsets.all(8),
                      ),
                    ),
                  ],
                ),
              ),

              // Content Section
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppTheme.backgroundColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // Scan Barcode Button
                        SizedBox(
                          width: double.infinity,
                          child: GradientButton(
                            text: 'SCAN BARCODE',
                            icon: Icons.qr_code_scanner,
                            onPressed: () async {
                              final result = await Navigator.pushNamed(
                                  context, '/qr-scanner');
                              if (result != null) {
                                setState(() {
                                  _barcodeController.text = result as String;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Barcode scanned: $result'),
                                    backgroundColor: AppTheme.successColor,
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              }
                            },
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Form Section
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Product Details',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        color: AppTheme.textPrimary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 24),

                                // Product Name Field
                                TextField(
                                  controller: _nameController,
                                  decoration: const InputDecoration(
                                    labelText: 'Product Name',
                                    hintText: 'Enter product name',
                                    prefixIcon: Icon(Icons.inventory_2),
                                  ),
                                ),

                                const SizedBox(height: 20),

                                // Price Field
                                TextField(
                                  controller: _priceController,
                                  decoration: const InputDecoration(
                                    labelText: 'Price',
                                    hintText: 'Enter price',
                                    prefixIcon: Icon(Icons.attach_money),
                                  ),
                                  keyboardType: TextInputType.number,
                                ),

                                const SizedBox(height: 20),

                                // Barcode Field
                                TextField(
                                  controller: _barcodeController,
                                  decoration: const InputDecoration(
                                    labelText: 'Barcode',
                                    hintText: 'Enter or scan barcode',
                                    prefixIcon: Icon(Icons.qr_code),
                                  ),
                                ),

                                const SizedBox(height: 40),

                                // Add Product Button
                                SizedBox(
                                  width: double.infinity,
                                  child: GradientButton(
                                    text: _isLoading
                                        ? 'ADDING...'
                                        : 'ADD PRODUCT',
                                    icon: _isLoading
                                        ? null
                                        : Icons.add_circle_outline,
                                    onPressed: _isLoading ? null : _addProduct,
                                  ),
                                ),

                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addProduct() async {
    if (_nameController.text.isEmpty || _priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fill in all required fields'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    final price = double.tryParse(_priceController.text);
    if (price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a valid price'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Check if barcode already exists
      if (_barcodeController.text.isNotEmpty) {
        final hasExistingBarcode =
            await _itemService.hasItemWithBarcode(_barcodeController.text);
        if (hasExistingBarcode) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('A product with this barcode already exists'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
          setState(() {
            _isLoading = false;
          });
          return;
        }
      }

      // Create new item
      final newItem = Item(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        price: price,
        barcode: _barcodeController.text,
      );

      // Add to service
      await _itemService.addItem(newItem);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Product "${newItem.name}" added successfully'),
          backgroundColor: AppTheme.successColor,
        ),
      );

      // Clear form
      _nameController.clear();
      _priceController.clear();
      _barcodeController.clear();

      // Navigate back
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add product: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}

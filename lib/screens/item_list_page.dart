import 'package:flutter/material.dart';
import '../models/item.dart';
import '../models/billing_item.dart';
import '../services/item_service.dart';
import '../services/session_service.dart';
import '../services/pdf_service.dart';
import '../theme/app_theme.dart';

class ItemListPage extends StatefulWidget {
  const ItemListPage({super.key});

  @override
  State<ItemListPage> createState() => _ItemListPageState();
}

class _ItemListPageState extends State<ItemListPage> {
  final ItemService _itemService = ItemService.instance;
  final SessionService _sessionService = SessionService.instance;
  final PDFService _pdfService = PDFService.instance;
  List<BillingItem> _billingItems = []; // Items in current bill
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
      _totalAmount =
          _billingItems.fold(0.0, (sum, item) => sum + item.totalPrice);
    });
    _saveSession(); // Auto-save session when total updates
  }

  Future<void> _addScannedItem(String scannedBarcode) async {
    try {
      // Check if product exists in catalog
      if (!(await _itemService.hasItemWithBarcode(scannedBarcode))) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Product not found in catalog. Please add it first.'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Get product from catalog
      final catalogItem = await _itemService.getItemByBarcode(scannedBarcode);

      // Check if item already exists in billing list
      final existingItemIndex = _billingItems.indexWhere(
        (billingItem) => billingItem.barcode == catalogItem.barcode,
      );

      if (existingItemIndex != -1) {
        // Item exists, increase quantity
        setState(() {
          _billingItems[existingItemIndex] =
              _billingItems[existingItemIndex].copyWith(
            quantity: _billingItems[existingItemIndex].quantity + 1,
          );
          _updateTotal();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Quantity increased: ${catalogItem.name} (${_billingItems[existingItemIndex].quantity})'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // New item, add to billing items
        setState(() {
          _billingItems.add(BillingItem.fromItem(catalogItem));
          _updateTotal();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Added: ${catalogItem.name} - ₹${catalogItem.price.toStringAsFixed(2)}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add item: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _increaseQuantity(int index) {
    setState(() {
      _billingItems[index] = _billingItems[index].copyWith(
        quantity: _billingItems[index].quantity + 1,
      );
      _updateTotal();
    });
  }

  void _decreaseQuantity(int index) {
    setState(() {
      if (_billingItems[index].quantity > 1) {
        _billingItems[index] = _billingItems[index].copyWith(
          quantity: _billingItems[index].quantity - 1,
        );
      } else {
        _billingItems.removeAt(index);
      }
      _updateTotal();
    });
  }

  void _removeItem(int index) {
    setState(() {
      _billingItems.removeAt(index);
      _updateTotal();
    });
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(60),
            ),
            child: Icon(
              Icons.shopping_cart_outlined,
              size: 60,
              color: AppTheme.primaryColor.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No items in bill yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap "SCAN BARCODE" to add items',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textHint,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildItemsList() {
    return ListView.builder(
      itemCount: _billingItems.length,
      itemBuilder: (context, index) {
        final item = _billingItems[index];
        return AnimatedCard(
          margin: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    if (item.barcode.isNotEmpty)
                      Text(
                        'Barcode: ${item.barcode}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.secondaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Direct Entry',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.secondaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ),
                    const SizedBox(height: 8),
                    Text(
                      '₹${item.totalPrice.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppTheme.successColor,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  _buildQuantityControls(item, index),
                  const SizedBox(width: 12),
                  _buildDeleteButton(index),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuantityControls(BillingItem item, int index) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () => _decreaseQuantity(index),
            icon: Icon(Icons.remove, color: AppTheme.errorColor, size: 18),
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              '${item.quantity}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          IconButton(
            onPressed: () => _increaseQuantity(index),
            icon: Icon(Icons.add, color: AppTheme.successColor, size: 18),
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteButton(int index) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.errorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        onPressed: () => _removeItem(index),
        icon: Icon(Icons.delete_outline, color: AppTheme.errorColor, size: 20),
        padding: const EdgeInsets.all(8),
        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
      ),
    );
  }

  Widget _buildTotalSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total Amount',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          Text(
            '₹${_totalAmount.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _showNewProductDialog,
            icon: const Icon(Icons.add_circle_outline, size: 20),
            label: const Text('Add New Product'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.secondaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: GradientButton(
            text: 'Generate Receipt',
            icon: Icons.receipt_long,
            onPressed: _billingItems.isEmpty ? null : _generateReceipt,
          ),
        ),
      ],
    );
  }

  Future<void> _generateReceipt() async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Generate PDF
      final pdfPath = await _pdfService.generateReceipt(
        _billingItems,
        _totalAmount,
      );

      // Close loading dialog
      Navigator.of(context).pop();

      // Open PDF
      await _pdfService.openPDF(pdfPath);

      // Clear session and bill
      await _sessionService.clearSession();
      setState(() {
        _billingItems.clear();
        _updateTotal();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Receipt generated and downloaded for ₹${_totalAmount.toStringAsFixed(2)}'),
          backgroundColor: AppTheme.successColor,
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      // Close loading dialog if it's open
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to generate receipt: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
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
                    _billingItems.add(BillingItem.fromItem(tempItem));
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
                            'Billing',
                            style: Theme.of(context)
                                .textTheme
                                .headlineLarge
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            'Scan & Bill Items',
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
                        onPressed: _billingItems.isEmpty ? null : _clearBill,
                        icon: Icon(
                          Icons.clear_all,
                          color: _billingItems.isEmpty
                              ? Colors.white.withOpacity(0.5)
                              : Colors.white,
                        ),
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
                        // Scan Button
                        SizedBox(
                          width: double.infinity,
                          child: GradientButton(
                            text: 'SCAN BARCODE',
                            icon: Icons.qr_code_scanner,
                            onPressed: () async {
                              final result = await Navigator.pushNamed(
                                  context, '/qr-scanner');
                              if (result != null) {
                                await _addScannedItem(result as String);
                              }
                            },
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Items Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Bill Items',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    color: AppTheme.textPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            if (_billingItems.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  '${_billingItems.length} items',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: AppTheme.primaryColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Items List
                        Expanded(
                          child: _isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : _billingItems.isEmpty
                                  ? _buildEmptyState(context)
                                  : _buildItemsList(),
                        ),

                        const SizedBox(height: 16),

                        // Total and Actions
                        if (_billingItems.isNotEmpty) ...[
                          _buildTotalSection(),
                          const SizedBox(height: 16),
                          _buildActionButtons(),
                        ],
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
}

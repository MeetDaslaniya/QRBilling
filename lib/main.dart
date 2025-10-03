import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/home_page.dart';
import 'screens/item_list_page.dart';
import 'screens/item_entry_page.dart';
import 'screens/qr_scanner_page.dart';
import 'screens/catalog_management_page.dart';
import 'services/item_service.dart';
import 'models/item.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register adapters
  Hive.registerAdapter(ItemAdapter());

  // Initialize ItemService
  await ItemService.instance.init();

  runApp(const BillingApp());
}

class BillingApp extends StatelessWidget {
  const BillingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Billing System',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/item-list': (context) => const ItemListPage(),
        '/item-entry': (context) => const ItemEntryPage(),
        '/qr-scanner': (context) => const QRScannerPage(),
        '/catalog-management': (context) => const CatalogManagementPage(),
      },
    );
  }
}

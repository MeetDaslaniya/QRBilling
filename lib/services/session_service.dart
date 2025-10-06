import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/billing_item.dart';

class SessionService {
  static SessionService? _instance;
  static SessionService get instance => _instance ??= SessionService._();

  SessionService._();

  static const String _sessionKey = 'billing_session';

  Future<void> saveSession(List<BillingItem> billingItems) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final itemsJson =
          billingItems.map((item) => jsonEncode(item.toJson())).toList();
      await prefs.setStringList(_sessionKey, itemsJson);
    } catch (e) {
      throw Exception('Failed to save session: $e');
    }
  }

  Future<List<BillingItem>> loadSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final itemsJson = prefs.getStringList(_sessionKey) ?? [];

      if (itemsJson.isEmpty) {
        return [];
      }

      return itemsJson.map((json) {
        final Map<String, dynamic> itemMap = jsonDecode(json);
        return BillingItem.fromJson(itemMap);
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> clearSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_sessionKey);
    } catch (e) {
      throw Exception('Failed to clear session: $e');
    }
  }

  Future<bool> hasActiveSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final itemsJson = prefs.getStringList(_sessionKey) ?? [];
      return itemsJson.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}

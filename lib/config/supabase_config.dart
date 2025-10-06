import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl = 'https://ypnbjerxrajszyszfcse.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlwbmJqZXJ4cmFqc3p5c3pmY3NlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk3NjU2MzAsImV4cCI6MjA3NTM0MTYzMH0.AWoRLA5pcQYc2hOyPSIJBAuGOxv364uN6Vzzs9Othgg';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}

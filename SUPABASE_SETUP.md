# QR Billing App - Supabase Setup

## Supabase Configuration

### 1. Create Supabase Project
1. Go to [supabase.com](https://supabase.com)
2. Create a new project
3. Note down your project URL and anon key

### 2. Update Configuration
Update `lib/config/supabase_config.dart` with your Supabase credentials:

```dart
class SupabaseConfig {
  static const String supabaseUrl = 'YOUR_SUPABASE_URL_HERE';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY_HERE';
  // ... rest of the code
}
```

### 3. Create Products Table
Run the SQL script in `supabase_setup.sql` in your Supabase SQL Editor:

```sql
-- Create products table for QR Billing App
CREATE TABLE products (
  id TEXT PRIMARY KEY,
  barcode TEXT NOT NULL UNIQUE,
  name TEXT NOT NULL,
  price DECIMAL(10,2) NOT NULL,
  date TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security (RLS) - but no policies for now as requested
ALTER TABLE products ENABLE ROW LEVEL SECURITY;

-- Create an index on barcode for faster lookups
CREATE INDEX idx_products_barcode ON products(barcode);

-- Create an index on date for ordering
CREATE INDEX idx_products_date ON products(date);

-- Enable real-time for the products table
ALTER PUBLICATION supabase_realtime ADD TABLE products;
```

### 4. Install Dependencies
```bash
flutter pub get
```

### 5. Run the App
```bash
flutter run
```

## Features

- ✅ Real-time product catalog updates
- ✅ QR/Barcode scanning for product lookup
- ✅ Add, edit, delete products
- ✅ Billing system with session persistence
- ✅ Supabase backend with real-time subscriptions

## Table Structure

The `products` table has the following fields:
- `id` (TEXT, PRIMARY KEY) - Unique identifier
- `barcode` (TEXT, UNIQUE) - Product barcode/QR code
- `name` (TEXT) - Product name
- `price` (DECIMAL) - Product price
- `date` (TIMESTAMP) - Creation/update date

## Real-time Updates

The app automatically updates the catalog when:
- New products are added
- Products are edited
- Products are deleted

All changes are synchronized in real-time across all connected devices.

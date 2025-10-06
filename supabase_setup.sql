-- Create products table for QR Billing App
-- Run this SQL in your Supabase SQL Editor

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

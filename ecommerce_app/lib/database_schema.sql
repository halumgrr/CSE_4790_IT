-- Ecommerce Database Schema for GhorerBazar-like app
-- Run these SQL commands in your Supabase SQL editor

-- Categories table
CREATE TABLE categories (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  name_bn TEXT, -- Bengali name
  description TEXT,
  image_url TEXT,
  parent_id UUID REFERENCES categories(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Products table
CREATE TABLE products (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  name_bn TEXT, -- Bengali name
  description TEXT,
  description_bn TEXT, -- Bengali description
  category_id UUID REFERENCES categories(id),
  price DECIMAL(10,2) NOT NULL,
  sale_price DECIMAL(10,2), -- For discounted items
  sku TEXT UNIQUE,
  stock_quantity INTEGER DEFAULT 0,
  weight TEXT, -- e.g., "500g", "1kg"
  unit TEXT, -- e.g., "piece", "kg", "liter"
  image_urls TEXT[], -- Array of image URLs
  is_organic BOOLEAN DEFAULT true,
  is_featured BOOLEAN DEFAULT false,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Cart items table
CREATE TABLE cart_items (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  product_id UUID REFERENCES products(id) ON DELETE CASCADE,
  quantity INTEGER NOT NULL DEFAULT 1,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, product_id)
);

-- Orders table
CREATE TABLE orders (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id),
  order_number TEXT UNIQUE NOT NULL,
  status TEXT DEFAULT 'pending', -- pending, confirmed, processing, shipped, delivered, cancelled
  total_amount DECIMAL(10,2) NOT NULL,
  shipping_address JSONB,
  billing_address JSONB,
  phone TEXT,
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Order items table
CREATE TABLE order_items (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  order_id UUID REFERENCES orders(id) ON DELETE CASCADE,
  product_id UUID REFERENCES products(id),
  quantity INTEGER NOT NULL,
  unit_price DECIMAL(10,2) NOT NULL,
  total_price DECIMAL(10,2) NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security (RLS)
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE cart_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;

-- RLS Policies

-- Categories: Public read access
CREATE POLICY "Categories are viewable by everyone" ON categories
  FOR SELECT USING (true);

-- Products: Public read access
CREATE POLICY "Products are viewable by everyone" ON products
  FOR SELECT USING (true);

-- Cart items: Users can only access their own cart
CREATE POLICY "Users can view own cart items" ON cart_items
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own cart items" ON cart_items
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own cart items" ON cart_items
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own cart items" ON cart_items
  FOR DELETE USING (auth.uid() = user_id);

-- Orders: Users can only access their own orders
CREATE POLICY "Users can view own orders" ON orders
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own orders" ON orders
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Order items: Users can only access their own order items
CREATE POLICY "Users can view own order items" ON order_items
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM orders 
      WHERE orders.id = order_items.order_id 
      AND orders.user_id = auth.uid()
    )
  );

-- Insert sample categories
INSERT INTO categories (name, name_bn, description) VALUES
('Honey & Ghee', 'মধু ও ঘি', 'Natural honey and organic ghee products'),
('Dates & Dried Fruits', 'খেজুর ও শুকনো ফল', 'Premium dates and dried fruits'),
('Oils & Vinegar', 'তেল ও ভিনেগার', 'Organic cooking oils and vinegar'),
('Spices', 'মসলা', 'Authentic Bengali spices'),
('Rice & Grains', 'চাল ও শস্য', 'Premium rice and grain varieties'),
('Nuts & Seeds', 'বাদাম ও বীজ', 'Fresh nuts and healthy seeds');

-- Insert sample products
INSERT INTO products (name, name_bn, description, category_id, price, sale_price, weight, unit, image_urls, is_organic, is_featured) VALUES
('Natural Honey', 'প্রাকৃতিক মধু', 'Pure natural honey from Bangladesh', 
 (SELECT id FROM categories WHERE name = 'Honey & Ghee'), 450.00, 400.00, '500g', 'jar', ARRAY['assets/images/natural_honey.webp'], true, true),
 
('Organic Ghee', 'জৈব ঘি', 'Traditional organic cow ghee', 
 (SELECT id FROM categories WHERE name = 'Honey & Ghee'), 800.00, NULL, '250g', 'jar', ARRAY['assets/images/organic_ghee.webp'], true, false),
 
('Medjool Dates', 'মেডজুল খেজুর', 'Premium quality Medjool dates', 
 (SELECT id FROM categories WHERE name = 'Dates & Dried Fruits'), 550.00, 500.00, '250g', 'pack', ARRAY['assets/images/medjool.webp'], true, true),
 
('Mustard Oil', 'সরিষার তেল', 'Cold pressed mustard oil', 
 (SELECT id FROM categories WHERE name = 'Oils & Vinegar'), 320.00, NULL, '1L', 'bottle', ARRAY['assets/images/mustard_oil.webp'], true, false),
 
('Basmati Rice', 'বাসমতি চাল', 'Premium basmati rice', 
 (SELECT id FROM categories WHERE name = 'Rice & Grains'), 180.00, 160.00, '1kg', 'pack', ARRAY['assets/images/basmati_rice.webp'], true, false),
 
('Mixed Nuts', 'মিশ্রিত বাদাম', 'Healthy mix of almonds, cashews, and walnuts', 
 (SELECT id FROM categories WHERE name = 'Nuts & Seeds'), 750.00, NULL, '200g', 'pack', ARRAY['assets/images/mixed_nuts.webp'], true, true);

-- Create functions for updated_at timestamps
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers for updated_at
CREATE TRIGGER update_categories_updated_at BEFORE UPDATE ON categories
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_products_updated_at BEFORE UPDATE ON products
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_cart_items_updated_at BEFORE UPDATE ON cart_items
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_orders_updated_at BEFORE UPDATE ON orders
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
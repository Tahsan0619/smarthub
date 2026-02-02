-- ================================================================
-- SAJIBMART SUPABASE SCHEMA - 100% MATCHING WITH APP CODE
-- ================================================================
-- Run this entire SQL in Supabase SQL Editor
-- ================================================================

-- Drop existing tables (in correct order due to foreign keys)
DROP TABLE IF EXISTS reviews CASCADE;
DROP TABLE IF EXISTS order_items CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS bookings CASCADE;
DROP TABLE IF EXISTS saved_houses CASCADE;
DROP TABLE IF EXISTS services CASCADE;
DROP TABLE IF EXISTS properties CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- ================================================================
-- 1. USERS TABLE
-- ================================================================
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  auth_id UUID UNIQUE NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT UNIQUE NOT NULL,
  display_name TEXT NOT NULL,
  phone_number TEXT,
  role TEXT NOT NULL CHECK (role IN ('student', 'owner', 'provider', 'admin')),
  profile_image_url TEXT,
  location TEXT,
  university TEXT,
  nid_number TEXT,
  is_verified BOOLEAN DEFAULT false,
  verification_date TIMESTAMPTZ,
  verified_by UUID,
  rating DECIMAL(3,2) DEFAULT 0.0,
  review_count INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ================================================================
-- 2. PROPERTIES TABLE (Houses/Accommodations)
-- ================================================================
CREATE TABLE properties (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  location TEXT NOT NULL,
  latitude DECIMAL(10,8),
  longitude DECIMAL(11,8),
  rent DECIMAL(10,2) NOT NULL,
  property_type TEXT,
  bedrooms INTEGER DEFAULT 1,
  bathrooms INTEGER DEFAULT 1,
  area TEXT,
  amenities TEXT[],
  images TEXT[],
  facilities TEXT[],
  status TEXT DEFAULT 'available',
  has_wifi BOOLEAN DEFAULT false,
  distance_from_campus DECIMAL(10,2) DEFAULT 0.0,
  room_type TEXT DEFAULT 'Single Room',
  is_available BOOLEAN DEFAULT true,
  rating DECIMAL(3,2) DEFAULT 0.0,
  review_count INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ================================================================
-- 3. SERVICES TABLE
-- ================================================================
CREATE TABLE services (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  provider_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  description TEXT,
  category TEXT NOT NULL,
  price DECIMAL(10,2) NOT NULL,
  price_unit TEXT DEFAULT 'per_hour',
  images TEXT[],
  delivery_time TEXT,
  subject TEXT,
  qualifications TEXT,
  experience_level TEXT,
  session_duration_minutes INTEGER,
  availability TEXT[],
  is_available BOOLEAN DEFAULT true,
  rating DECIMAL(3,2) DEFAULT 0.0,
  review_count INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ================================================================
-- 4. BOOKINGS TABLE (Property Bookings)
-- ================================================================
CREATE TABLE bookings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  property_id UUID NOT NULL REFERENCES properties(id) ON DELETE CASCADE,
  student_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  owner_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  check_in_date DATE NOT NULL,
  check_out_date DATE NOT NULL,
  total_amount DECIMAL(10,2) NOT NULL,
  notes TEXT,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected', 'confirmed', 'cancelled', 'completed')),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ================================================================
-- 5. ORDERS TABLE (Service Orders)
-- ================================================================
CREATE TABLE orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  provider_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  total_amount DECIMAL(10,2) NOT NULL,
  delivery_address TEXT,
  notes TEXT,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected', 'confirmed', 'in_progress', 'completed', 'cancelled')),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ================================================================
-- 6. ORDER_ITEMS TABLE
-- ================================================================
CREATE TABLE order_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  service_id UUID NOT NULL REFERENCES services(id) ON DELETE CASCADE,
  quantity INTEGER NOT NULL DEFAULT 1,
  price DECIMAL(10,2) NOT NULL,
  subtotal DECIMAL(10,2) NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ================================================================
-- 7. SAVED_HOUSES TABLE (User Favorites)
-- ================================================================
CREATE TABLE saved_houses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  property_id UUID NOT NULL REFERENCES properties(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, property_id)
);

-- ================================================================
-- 8. REVIEWS TABLE
-- ================================================================
CREATE TABLE reviews (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  reviewer_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  property_id UUID REFERENCES properties(id) ON DELETE CASCADE,
  service_id UUID REFERENCES services(id) ON DELETE CASCADE,
  rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
  comment TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  CHECK (property_id IS NOT NULL OR service_id IS NOT NULL)
);

-- ================================================================
-- INDEXES FOR PERFORMANCE
-- ================================================================
CREATE INDEX idx_users_auth_id ON users(auth_id);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_properties_owner_id ON properties(owner_id);
CREATE INDEX idx_properties_is_available ON properties(is_available);
CREATE INDEX idx_services_provider_id ON services(provider_id);
CREATE INDEX idx_services_category ON services(category);
CREATE INDEX idx_bookings_student_id ON bookings(student_id);
CREATE INDEX idx_bookings_owner_id ON bookings(owner_id);
CREATE INDEX idx_bookings_property_id ON bookings(property_id);
CREATE INDEX idx_orders_student_id ON orders(student_id);
CREATE INDEX idx_orders_provider_id ON orders(provider_id);
CREATE INDEX idx_order_items_order_id ON order_items(order_id);
CREATE INDEX idx_saved_houses_user_id ON saved_houses(user_id);
CREATE INDEX idx_reviews_property_id ON reviews(property_id);
CREATE INDEX idx_reviews_service_id ON reviews(service_id);

-- ================================================================
-- ENABLE ROW LEVEL SECURITY
-- ================================================================
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE properties ENABLE ROW LEVEL SECURITY;
ALTER TABLE services ENABLE ROW LEVEL SECURITY;
ALTER TABLE bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE saved_houses ENABLE ROW LEVEL SECURITY;
ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;

-- ================================================================
-- RLS POLICIES - USERS
-- ================================================================
CREATE POLICY "Anyone can read users" ON users FOR SELECT USING (true);
CREATE POLICY "Users can insert own profile" ON users FOR INSERT WITH CHECK (true);
CREATE POLICY "Users can update own profile" ON users FOR UPDATE USING (auth.uid() = auth_id);
CREATE POLICY "Admins can update users" ON users FOR UPDATE USING (
  EXISTS (SELECT 1 FROM users WHERE auth_id = auth.uid() AND role = 'admin')
);
CREATE POLICY "Admins can delete users" ON users FOR DELETE USING (
  EXISTS (SELECT 1 FROM users WHERE auth_id = auth.uid() AND role = 'admin')
);

-- ================================================================
-- RLS POLICIES - PROPERTIES
-- ================================================================
CREATE POLICY "Anyone can read properties" ON properties FOR SELECT USING (true);
CREATE POLICY "Owners can insert properties" ON properties FOR INSERT WITH CHECK (
  EXISTS (SELECT 1 FROM users WHERE id = owner_id AND auth_id = auth.uid())
);
CREATE POLICY "Owners can update own properties" ON properties FOR UPDATE USING (
  EXISTS (SELECT 1 FROM users WHERE id = owner_id AND auth_id = auth.uid())
);
CREATE POLICY "Owners can delete own properties" ON properties FOR DELETE USING (
  EXISTS (SELECT 1 FROM users WHERE id = owner_id AND auth_id = auth.uid())
);

-- ================================================================
-- RLS POLICIES - SERVICES
-- ================================================================
CREATE POLICY "Anyone can read services" ON services FOR SELECT USING (true);
CREATE POLICY "Providers can insert services" ON services FOR INSERT WITH CHECK (
  EXISTS (SELECT 1 FROM users WHERE id = provider_id AND auth_id = auth.uid())
);
CREATE POLICY "Providers can update own services" ON services FOR UPDATE USING (
  EXISTS (SELECT 1 FROM users WHERE id = provider_id AND auth_id = auth.uid())
);
CREATE POLICY "Providers can delete own services" ON services FOR DELETE USING (
  EXISTS (SELECT 1 FROM users WHERE id = provider_id AND auth_id = auth.uid())
);

-- ================================================================
-- RLS POLICIES - BOOKINGS
-- ================================================================
CREATE POLICY "Users can read own bookings" ON bookings FOR SELECT USING (
  EXISTS (SELECT 1 FROM users WHERE id IN (student_id, owner_id) AND auth_id = auth.uid())
);
CREATE POLICY "Owners can read bookings for their properties" ON bookings FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM properties
    WHERE id = property_id
      AND EXISTS (SELECT 1 FROM users WHERE id = owner_id AND auth_id = auth.uid())
  )
);
CREATE POLICY "Students can create bookings" ON bookings FOR INSERT WITH CHECK (
  EXISTS (SELECT 1 FROM users WHERE id = student_id AND auth_id = auth.uid())
);
CREATE POLICY "Booking parties can update" ON bookings FOR UPDATE USING (
  EXISTS (SELECT 1 FROM users WHERE id IN (student_id, owner_id) AND auth_id = auth.uid())
  OR EXISTS (
    SELECT 1 FROM properties
    WHERE id = property_id
      AND EXISTS (SELECT 1 FROM users WHERE id = owner_id AND auth_id = auth.uid())
  )
);
CREATE POLICY "Booking parties can delete" ON bookings FOR DELETE USING (
  EXISTS (SELECT 1 FROM users WHERE id IN (student_id, owner_id) AND auth_id = auth.uid())
  OR EXISTS (
    SELECT 1 FROM properties
    WHERE id = property_id
      AND EXISTS (SELECT 1 FROM users WHERE id = owner_id AND auth_id = auth.uid())
  )
);

-- ================================================================
-- RLS POLICIES - ORDERS
-- ================================================================
CREATE POLICY "Users can read own orders" ON orders FOR SELECT USING (
  EXISTS (SELECT 1 FROM users WHERE id IN (student_id, provider_id) AND auth_id = auth.uid())
);
CREATE POLICY "Students can create orders" ON orders FOR INSERT WITH CHECK (
  EXISTS (SELECT 1 FROM users WHERE id = student_id AND auth_id = auth.uid())
);
CREATE POLICY "Order parties can update" ON orders FOR UPDATE USING (
  EXISTS (SELECT 1 FROM users WHERE id IN (student_id, provider_id) AND auth_id = auth.uid())
);
CREATE POLICY "Order parties can delete" ON orders FOR DELETE USING (
  EXISTS (SELECT 1 FROM users WHERE id IN (student_id, provider_id) AND auth_id = auth.uid())
);

-- ================================================================
-- RLS POLICIES - ORDER_ITEMS
-- ================================================================
CREATE POLICY "Users can read own order items" ON order_items FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM orders o 
    JOIN users u ON u.id IN (o.student_id, o.provider_id) 
    WHERE o.id = order_id AND u.auth_id = auth.uid()
  )
);
CREATE POLICY "Users can insert order items" ON order_items FOR INSERT WITH CHECK (
  EXISTS (
    SELECT 1 FROM orders o 
    JOIN users u ON u.id = o.student_id 
    WHERE o.id = order_id AND u.auth_id = auth.uid()
  )
);
CREATE POLICY "Users can delete order items" ON order_items FOR DELETE USING (
  EXISTS (
    SELECT 1 FROM orders o 
    JOIN users u ON u.id IN (o.student_id, o.provider_id) 
    WHERE o.id = order_id AND u.auth_id = auth.uid()
  )
);

-- ================================================================
-- RLS POLICIES - SAVED_HOUSES
-- ================================================================
CREATE POLICY "Users can read own saved houses" ON saved_houses FOR SELECT USING (
  EXISTS (SELECT 1 FROM users WHERE id = user_id AND auth_id = auth.uid())
);
CREATE POLICY "Users can save houses" ON saved_houses FOR INSERT WITH CHECK (
  EXISTS (SELECT 1 FROM users WHERE id = user_id AND auth_id = auth.uid())
);
CREATE POLICY "Users can unsave houses" ON saved_houses FOR DELETE USING (
  EXISTS (SELECT 1 FROM users WHERE id = user_id AND auth_id = auth.uid())
);

-- ================================================================
-- RLS POLICIES - REVIEWS
-- ================================================================
CREATE POLICY "Anyone can read reviews" ON reviews FOR SELECT USING (true);
CREATE POLICY "Users can create reviews" ON reviews FOR INSERT WITH CHECK (
  EXISTS (SELECT 1 FROM users WHERE id = reviewer_id AND auth_id = auth.uid())
);
CREATE POLICY "Users can update own reviews" ON reviews FOR UPDATE USING (
  EXISTS (SELECT 1 FROM users WHERE id = reviewer_id AND auth_id = auth.uid())
);
CREATE POLICY "Users can delete own reviews" ON reviews FOR DELETE USING (
  EXISTS (SELECT 1 FROM users WHERE id = reviewer_id AND auth_id = auth.uid())
);

-- ================================================================
-- ENABLE REALTIME (ignore errors if already added)
-- ================================================================
DO $$
BEGIN
  ALTER PUBLICATION supabase_realtime ADD TABLE users;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$
BEGIN
  ALTER PUBLICATION supabase_realtime ADD TABLE properties;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$
BEGIN
  ALTER PUBLICATION supabase_realtime ADD TABLE services;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$
BEGIN
  ALTER PUBLICATION supabase_realtime ADD TABLE bookings;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$
BEGIN
  ALTER PUBLICATION supabase_realtime ADD TABLE orders;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- ================================================================
-- DONE! Schema is ready.
-- ================================================================

-- ================================================================
-- NEXT: INSERT SUPERADMIN (run this AFTER creating auth user)
-- ================================================================
-- First create the auth user in Supabase Dashboard:
--   Authentication -> Users -> Add User
--   Email: sajibvai.ituapu@gmail.com
--   Password: smarthub
--
-- Then run this:
-- INSERT INTO users (auth_id, email, display_name, phone_number, role, is_verified)
-- VALUES (
--   (SELECT id FROM auth.users WHERE email = 'sajibvai.ituapu@gmail.com'),
--   'sajibvai.ituapu@gmail.com',
--   'Super Admin',
--   '01700000000',
--   'admin',
--   true
-- );
-- ================================================================

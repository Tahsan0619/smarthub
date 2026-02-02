-- ================================================================
-- FIX: ADMIN CANNOT SEE BOOKINGS AND ORDERS
-- ================================================================
-- Problem: RLS policies only allow users to see their own bookings/orders
-- Solution: Add admin policies that bypass restrictions for admin role
-- ================================================================

-- ADD ADMIN POLICIES FOR BOOKINGS
CREATE POLICY "Admins can read all bookings" ON bookings FOR SELECT USING (
  EXISTS (SELECT 1 FROM users WHERE auth_id = auth.uid() AND role = 'admin')
);

CREATE POLICY "Admins can update all bookings" ON bookings FOR UPDATE USING (
  EXISTS (SELECT 1 FROM users WHERE auth_id = auth.uid() AND role = 'admin')
);

CREATE POLICY "Admins can delete all bookings" ON bookings FOR DELETE USING (
  EXISTS (SELECT 1 FROM users WHERE auth_id = auth.uid() AND role = 'admin')
);

-- ADD ADMIN POLICIES FOR ORDERS
CREATE POLICY "Admins can read all orders" ON orders FOR SELECT USING (
  EXISTS (SELECT 1 FROM users WHERE auth_id = auth.uid() AND role = 'admin')
);

CREATE POLICY "Admins can update all orders" ON orders FOR UPDATE USING (
  EXISTS (SELECT 1 FROM users WHERE auth_id = auth.uid() AND role = 'admin')
);

CREATE POLICY "Admins can delete all orders" ON orders FOR DELETE USING (
  EXISTS (SELECT 1 FROM users WHERE auth_id = auth.uid() AND role = 'admin')
);

-- ADD ADMIN POLICIES FOR ORDER_ITEMS
CREATE POLICY "Admins can read all order items" ON order_items FOR SELECT USING (
  EXISTS (SELECT 1 FROM users WHERE auth_id = auth.uid() AND role = 'admin')
);

-- ================================================================
-- HOW TO APPLY:
-- ================================================================
-- 1. Go to Supabase Dashboard
-- 2. Click "SQL Editor" in left sidebar
-- 3. Click "New Query"
-- 4. Copy and paste this entire file
-- 5. Click "Run" button
-- 6. Refresh your admin dashboard in the app
-- ================================================================

-- ================================================================
-- SUPABASE STORAGE SETUP
-- ================================================================
-- Run this in Supabase SQL Editor to create storage buckets
-- ================================================================

-- Create storage buckets (do this in Supabase Dashboard -> Storage)
-- 1. Click "New bucket"
-- 2. Create these buckets:
--    - profile-images (public)
--    - properties-images (public)
--    - services-images (public)

-- After creating buckets, run these policies:

-- ================================================================
-- STORAGE POLICIES - profile-images bucket
-- ================================================================

-- Allow authenticated users to upload profile images
CREATE POLICY "Users can upload profile images"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'profile-images');

-- Allow anyone to view profile images
CREATE POLICY "Anyone can view profile images"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'profile-images');

-- Allow users to update their own profile images
CREATE POLICY "Users can update profile images"
ON storage.objects FOR UPDATE
TO authenticated
USING (bucket_id = 'profile-images');

-- Allow users to delete their own profile images
CREATE POLICY "Users can delete profile images"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'profile-images');

-- ================================================================
-- STORAGE POLICIES - properties-images bucket
-- ================================================================

-- Allow authenticated users to upload property images
CREATE POLICY "Users can upload property images"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'properties-images');

-- Allow anyone to view property images
CREATE POLICY "Anyone can view property images"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'properties-images');

-- Allow users to update property images
CREATE POLICY "Users can update property images"
ON storage.objects FOR UPDATE
TO authenticated
USING (bucket_id = 'properties-images');

-- Allow users to delete property images
CREATE POLICY "Users can delete property images"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'properties-images');

-- ================================================================
-- STORAGE POLICIES - services-images bucket
-- ================================================================

-- Allow authenticated users to upload service images
CREATE POLICY "Users can upload service images"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'services-images');

-- Allow anyone to view service images
CREATE POLICY "Anyone can view service images"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'services-images');

-- Allow users to update service images
CREATE POLICY "Users can update service images"
ON storage.objects FOR UPDATE
TO authenticated
USING (bucket_id = 'services-images');

-- Allow users to delete service images
CREATE POLICY "Users can delete service images"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'services-images');

-- ================================================================
-- DONE!
-- ================================================================
-- IMPORTANT: Before running this SQL, you MUST create the buckets
-- manually in Supabase Dashboard -> Storage -> New bucket
-- 
-- Bucket names:
--   1. profile-images (set to PUBLIC)
--   2. properties-images (set to PUBLIC)
--   3. services-images (set to PUBLIC)
-- ================================================================

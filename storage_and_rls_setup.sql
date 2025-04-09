-- =============================================
-- Storage Bucket Setup for Attendance Management System
-- =============================================
-- This script sets up the storage buckets and RLS policies needed for the app
-- Run this in the Supabase SQL Editor after running the main database setup script

BEGIN;

-- =============================================
-- STEP 1: Create Storage Buckets
-- =============================================

-- Create profile_images bucket for user profile pictures
INSERT INTO storage.buckets (id, name, public) 
VALUES ('profile_images', 'profile_images', true)
ON CONFLICT (id) DO NOTHING;

-- Create class_attachments bucket for any class-related files
INSERT INTO storage.buckets (id, name, public) 
VALUES ('class_attachments', 'class_attachments', false)
ON CONFLICT (id) DO NOTHING;

-- =============================================
-- STEP 2: Set up RLS for Storage Buckets
-- =============================================

-- Enable RLS on the buckets
ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

-- Profile Images Bucket Policies
-- Allow users to view any profile image (since bucket is public)
CREATE POLICY "Public profiles are viewable by everyone" 
ON storage.objects FOR SELECT
USING (bucket_id = 'profile_images');

-- Allow users to upload their own profile image
CREATE POLICY "Users can upload their own profile image" 
ON storage.objects FOR INSERT 
WITH CHECK (
  bucket_id = 'profile_images' AND 
  auth.uid()::text = (storage.foldername(name))[1]
);

-- Allow users to update their own profile image
CREATE POLICY "Users can update their own profile image" 
ON storage.objects FOR UPDATE
USING (
  bucket_id = 'profile_images' AND 
  auth.uid()::text = (storage.foldername(name))[1]
);

-- Allow users to delete their own profile image
CREATE POLICY "Users can delete their own profile image" 
ON storage.objects FOR DELETE
USING (
  bucket_id = 'profile_images' AND 
  auth.uid()::text = (storage.foldername(name))[1]
);

-- Class Attachments Bucket Policies
-- Allow teachers to view attachments for their classes
CREATE POLICY "Teachers can view their class attachments" 
ON storage.objects FOR SELECT
USING (
  bucket_id = 'class_attachments' AND 
  EXISTS (
    SELECT 1 FROM classes
    WHERE classes.id::text = (storage.foldername(name))[1]
    AND classes.teacher_id = auth.uid()
  )
);

-- Allow teachers to upload attachments to their classes
CREATE POLICY "Teachers can upload attachments to their classes" 
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'class_attachments' AND 
  EXISTS (
    SELECT 1 FROM classes
    WHERE classes.id::text = (storage.foldername(name))[1]
    AND classes.teacher_id = auth.uid()
  )
);

-- Allow teachers to update attachments for their classes
CREATE POLICY "Teachers can update their class attachments" 
ON storage.objects FOR UPDATE
USING (
  bucket_id = 'class_attachments' AND 
  EXISTS (
    SELECT 1 FROM classes
    WHERE classes.id::text = (storage.foldername(name))[1]
    AND classes.teacher_id = auth.uid()
  )
);

-- Allow teachers to delete attachments for their classes
CREATE POLICY "Teachers can delete their class attachments" 
ON storage.objects FOR DELETE
USING (
  bucket_id = 'class_attachments' AND 
  EXISTS (
    SELECT 1 FROM classes
    WHERE classes.id::text = (storage.foldername(name))[1]
    AND classes.teacher_id = auth.uid()
  )
);

-- =============================================
-- STEP 3: Additional RLS Policies for Database Tables
-- =============================================

-- Allow users to delete their own account data
CREATE POLICY "Users can delete their own data" 
ON users FOR DELETE 
USING (auth.uid() = id);

-- Allow admin users to view all users
CREATE POLICY "Admins can view all users" 
ON users FOR SELECT 
USING (
  EXISTS (
    SELECT 1 FROM users 
    WHERE users.id = auth.uid() AND users.role = 'admin'
  )
);

-- Allow admin users to manage subjects
CREATE POLICY "Admins can insert subjects" 
ON subjects FOR INSERT 
WITH CHECK (
  EXISTS (
    SELECT 1 FROM users 
    WHERE users.id = auth.uid() AND users.role = 'admin'
  )
);

CREATE POLICY "Admins can update subjects" 
ON subjects FOR UPDATE 
USING (
  EXISTS (
    SELECT 1 FROM users 
    WHERE users.id = auth.uid() AND users.role = 'admin'
  )
);

CREATE POLICY "Admins can delete subjects" 
ON subjects FOR DELETE 
USING (
  EXISTS (
    SELECT 1 FROM users 
    WHERE users.id = auth.uid() AND users.role = 'admin'
  )
);

-- Allow admin users to manage courses
CREATE POLICY "Admins can insert courses" 
ON courses FOR INSERT 
WITH CHECK (
  EXISTS (
    SELECT 1 FROM users 
    WHERE users.id = auth.uid() AND users.role = 'admin'
  )
);

CREATE POLICY "Admins can update courses" 
ON courses FOR UPDATE 
USING (
  EXISTS (
    SELECT 1 FROM users 
    WHERE users.id = auth.uid() AND users.role = 'admin'
  )
);

CREATE POLICY "Admins can delete courses" 
ON courses FOR DELETE 
USING (
  EXISTS (
    SELECT 1 FROM users 
    WHERE users.id = auth.uid() AND users.role = 'admin'
  )
);

-- Allow teachers to update students they've created
CREATE POLICY "Teachers can update students in their classes" 
ON students FOR UPDATE 
USING (
  EXISTS (
    SELECT 1 FROM class_students cs
    JOIN classes c ON cs.class_id = c.id
    WHERE cs.student_id = students.id
    AND c.teacher_id = auth.uid()
  )
);

-- Allow teachers to delete students they've created
CREATE POLICY "Teachers can delete students in their classes" 
ON students FOR DELETE 
USING (
  EXISTS (
    SELECT 1 FROM class_students cs
    JOIN classes c ON cs.class_id = c.id
    WHERE cs.student_id = students.id
    AND c.teacher_id = auth.uid()
  )
);

-- =============================================
-- STEP 4: Create function for account deletion
-- =============================================

-- Function to handle complete user account deletion
CREATE OR REPLACE FUNCTION delete_user_account(user_id UUID)
RETURNS VOID AS $$
DECLARE
    class_ids UUID[];
BEGIN
    -- Get all class IDs owned by this user
    SELECT ARRAY_AGG(id) INTO class_ids FROM classes WHERE teacher_id = user_id;
    
    -- Delete attendance records for all sessions in user's classes
    DELETE FROM attendance_records
    WHERE session_id IN (
        SELECT id FROM attendance_sessions
        WHERE class_id = ANY(class_ids)
    );
    
    -- Delete attendance sessions for user's classes
    DELETE FROM attendance_sessions
    WHERE class_id = ANY(class_ids);
    
    -- Delete student-class relationships
    DELETE FROM class_students
    WHERE class_id = ANY(class_ids);
    
    -- Delete classes
    DELETE FROM classes
    WHERE teacher_id = user_id;
    
    -- Delete user record
    DELETE FROM users
    WHERE id = user_id;
    
    -- Note: The auth.users record will need to be deleted separately
    -- using supabase.auth.admin.deleteUser() from your application
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION delete_user_account TO authenticated;

-- =============================================
-- STEP 5: Commit all changes
-- =============================================
COMMIT;

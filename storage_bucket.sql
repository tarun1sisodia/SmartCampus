-- Create a storage bucket for profile images
INSERT INTO storage.buckets (id, name, public)
VALUES ('profile_images', 'profile_images', true);

-- Set up RLS policies for the bucket
CREATE POLICY "Users can view profile images"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'profile_images');

CREATE POLICY "Users can upload their own profile image"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'profile_images' AND
    (storage.foldername(name))[1] = auth.uid()::text
  );

CREATE POLICY "Users can update their own profile image"
  ON storage.objects FOR UPDATE
  USING (
    bucket_id = 'profile_images' AND
    (storage.foldername(name))[1] = auth.uid()::text
  );

CREATE POLICY "Users can delete their own profile image"
  ON storage.objects FOR DELETE
  USING (
    bucket_id = 'profile_images' AND
    (storage.foldername(name))[1] = auth.uid()::text
  );

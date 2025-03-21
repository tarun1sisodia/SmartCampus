-- Enable Row Level Security on the users table
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- Create policies for the users table

-- 1. Allow users to view their own data
CREATE POLICY "Users can view their own data"
    ON public.users
    FOR SELECT
    USING (auth.uid() = id);

-- 2. Allow users to insert their own data
CREATE POLICY "Users can insert their own data"
    ON public.users
    FOR INSERT
    WITH CHECK (auth.uid() = id);

-- 3. Allow users to update their own data
CREATE POLICY "Users can update their own data"
    ON public.users
    FOR UPDATE
    USING (auth.uid() = id);

-- 4. Allow users to delete their own data (optional)
CREATE POLICY "Users can delete their own data"
    ON public.users
    FOR DELETE
    USING (auth.uid() = id);

-- 5. Allow service role to access all data (for admin functions)
CREATE POLICY "Service role has full access"
    ON public.users
    USING (auth.role() = 'service_role');

-- Grant permissions to authenticated users
GRANT SELECT, INSERT, UPDATE, DELETE ON public.users TO authenticated;

-- Grant permissions to anon users (only if needed for public profiles)
-- GRANT SELECT ON public.users TO anon;


-- Rememeber You will be facing this issue so use this--

-- Drop existing policies first
DROP POLICY IF EXISTS "Users can view their own data" ON public.users;
DROP POLICY IF EXISTS "Users can insert their own data" ON public.users;
DROP POLICY IF EXISTS "Users can update their own data" ON public.users;
DROP POLICY IF EXISTS "Users can delete their own data" ON public.users;
DROP POLICY IF EXISTS "Service role has full access" ON public.users;

-- Then create the policies again
CREATE POLICY "Users can view their own data"
    ON public.users
    FOR SELECT
    USING (auth.uid() = id);

CREATE POLICY "Users can insert their own data"
    ON public.users
    FOR INSERT
    WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update their own data"
    ON public.users
    FOR UPDATE
    USING (auth.uid() = id);

CREATE POLICY "Users can delete their own data"
    ON public.users
    FOR DELETE
    USING (auth.uid() = id);

CREATE POLICY "Service role has full access"
    ON public.users
    USING (auth.role() = 'service_role');

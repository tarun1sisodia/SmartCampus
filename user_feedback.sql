CREATE TABLE user_feedback (
  id SERIAL PRIMARY KEY,
  user_id TEXT NOT NULL,
  user_email TEXT,
  rating INTEGER NOT NULL,
  feedback TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS on the table
ALTER TABLE user_feedback ENABLE ROW LEVEL SECURITY;

-- Create policy for inserting feedback (any authenticated user can submit feedback)
CREATE POLICY "Users can insert their own feedback" 
ON user_feedback 
FOR INSERT 
WITH CHECK (auth.uid()::text = user_id OR user_id = 'anonymous');

-- Create policy for viewing feedback (only admins can view all feedback)
CREATE POLICY "Only admins can view feedback" 
ON user_feedback 
FOR SELECT 
USING (auth.jwt() ->> 'role' = 'admin');

-- Create policy for users to view their own feedback
CREATE POLICY "Users can view their own feedback" 
ON user_feedback 
FOR SELECT 
USING (auth.uid()::text = user_id);

-- No update or delete policies (feedback should be immutable)

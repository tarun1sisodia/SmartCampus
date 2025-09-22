-- =============================================
-- Complete Database Setup for Attendance Management System
-- =============================================
-- This script sets up the entire database structure, RLS policies,
-- and storage buckets for the SmartCampus attendance app

BEGIN;

-- =============================================
-- STEP 1: Create Tables
-- =============================================

-- Users table for teacher/admin profiles
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    phone TEXT,
    profile_image_url TEXT,
    role TEXT DEFAULT 'teacher' CHECK (role IN ('teacher', 'admin')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ
);

-- Subjects table
CREATE TABLE IF NOT EXISTS subjects (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    code TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ
);

-- Courses table
CREATE TABLE IF NOT EXISTS courses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    code TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ
);

-- Classes table (represents a teacher's class for a specific subject and course)
CREATE TABLE IF NOT EXISTS classes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    teacher_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    subject_id UUID NOT NULL REFERENCES subjects(id) ON DELETE RESTRICT,
    course_id UUID NOT NULL REFERENCES courses(id) ON DELETE RESTRICT,
    semester INT NOT NULL,
    section TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    UNIQUE(teacher_id, subject_id, course_id, semester, section)
);

-- Students table
CREATE TABLE IF NOT EXISTS students (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    roll_number TEXT NOT NULL UNIQUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ
);

-- Class-Student relationship (many-to-many)
CREATE TABLE IF NOT EXISTS class_students (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    class_id UUID NOT NULL REFERENCES classes(id) ON DELETE CASCADE,
    student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(class_id, student_id)
);

-- Attendance Sessions table
CREATE TABLE IF NOT EXISTS attendance_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    class_id UUID NOT NULL REFERENCES classes(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    start_time TEXT,
    end_time TEXT,
    created_by UUID NOT NULL REFERENCES users(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    UNIQUE(class_id, date)
);

-- Attendance Records table
CREATE TABLE IF NOT EXISTS attendance_records (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id UUID NOT NULL REFERENCES attendance_sessions(id) ON DELETE CASCADE,
    student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
    status TEXT NOT NULL CHECK (status IN ('present', 'absent', 'late', 'excused')),
    remarks TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    UNIQUE(session_id, student_id)
);

-- User Feedback table
CREATE TABLE IF NOT EXISTS user_feedback (
    id SERIAL PRIMARY KEY,
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
     user_email TEXT,
    rating INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 5),
    feedback TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =============================================
-- STEP 2: Create Views
-- =============================================

-- Class view with subject and course names
CREATE OR REPLACE VIEW class_details AS
SELECT 
    c.id,
    c.teacher_id,
    c.subject_id,
    c.course_id,
    c.semester,
    c.section,
    s.name AS subject_name,
    co.name AS course_name,
    c.created_at,
    c.updated_at
FROM 
    classes c
JOIN 
    subjects s ON c.subject_id = s.id
JOIN 
    courses co ON c.course_id = co.id;

-- Attendance session view with class details
CREATE OR REPLACE VIEW attendance_session_details AS
SELECT 
    a.id,
    a.class_id,
    a.date,
    a.start_time,
    a.end_time,
    a.created_by,
    c.subject_name,
    c.course_name,
    c.semester,
    c.section,
    a.created_at,
    a.updated_at
FROM 
    attendance_sessions a
JOIN 
    class_details c ON a.class_id = c.id;

-- =============================================
-- STEP 3: Create Functions
-- =============================================

-- Function to handle new user creation
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    BEGIN
        INSERT INTO users (id, name, email, created_at)
        VALUES (
            NEW.id, 
            COALESCE(NEW.raw_user_meta_data->>'name', 'New User'), 
            NEW.email, 
            NOW()
        );
    EXCEPTION WHEN OTHERS THEN
        RAISE LOG 'Error creating user record: %', SQLERRM;
    END;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to add a student to a class
CREATE OR REPLACE FUNCTION add_student_to_class(
    p_class_id UUID,
    p_student_name TEXT,
    p_roll_number TEXT
)
RETURNS UUID AS $$
DECLARE
    v_student_id UUID;
    v_exists BOOLEAN;
BEGIN
    -- Check if student exists
    SELECT id INTO v_student_id
    FROM students
    WHERE roll_number = p_roll_number;
    
    IF v_student_id IS NULL THEN
        -- Create new student
        INSERT INTO students (name, roll_number, created_at)
        VALUES (p_student_name, p_roll_number, NOW())
        RETURNING id INTO v_student_id;
    ELSE
        -- Update student name if it has changed
        UPDATE students 
        SET name = p_student_name, updated_at = NOW()
        WHERE id = v_student_id AND name != p_student_name;
    END IF;
    
    -- Check if student is already in the class
    SELECT EXISTS(
        SELECT 1 FROM class_students 
        WHERE class_id = p_class_id AND student_id = v_student_id
    ) INTO v_exists;
    
    IF v_exists THEN
        RAISE EXCEPTION 'Student with roll number % is already in this class', p_roll_number;
    END IF;
    
    -- Add student to class
    INSERT INTO class_students (class_id, student_id, created_at)
    VALUES (p_class_id, v_student_id, NOW());
    
    RETURN v_student_id;
EXCEPTION
    WHEN unique_violation THEN
        RAISE EXCEPTION 'Student with roll number % already exists', p_roll_number;
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error adding student to class: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- Function to submit attendance
CREATE OR REPLACE FUNCTION submit_attendance(
    p_session_id UUID,
    p_student_id UUID,
    p_status TEXT,
    p_remarks TEXT DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
    v_record_id UUID;
    v_exists BOOLEAN;
BEGIN
    -- Check if record exists
    SELECT EXISTS(
        SELECT 1 FROM attendance_records
        WHERE session_id = p_session_id AND student_id = p_student_id
    ) INTO v_exists;
    
    IF v_exists THEN
        -- Update existing record
        UPDATE attendance_records
        SET status = p_status, 
            remarks = p_remarks,
            updated_at = NOW()
        WHERE session_id = p_session_id AND student_id = p_student_id
        RETURNING id INTO v_record_id;
    ELSE
        -- Create new record
        INSERT INTO attendance_records (session_id, student_id, status, remarks, created_at)
        VALUES (p_session_id, p_student_id, p_status, p_remarks, NOW())
        RETURNING id INTO v_record_id;
    END IF;
    
    RETURN v_record_id;
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error submitting attendance: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- Function to get attendance statistics for a class
CREATE OR REPLACE FUNCTION get_class_attendance_stats(p_class_id UUID)
RETURNS TABLE (
    total_sessions INT,
    present_count INT,
    absent_count INT,
    late_count INT,
    excused_count INT,
    average_attendance NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    WITH session_counts AS (
        SELECT COUNT(*) AS session_count
        FROM attendance_sessions
        WHERE class_id = p_class_id
    ),
    student_counts AS (
        SELECT COUNT(*) AS student_count
        FROM class_students
        WHERE class_id = p_class_id
    ),
    status_counts AS (
        SELECT 
            ar.status,
            COUNT(*) AS count
        FROM 
            attendance_records ar
        JOIN 
            attendance_sessions as_session ON ar.session_id = as_session.id
        WHERE 
            as_session.class_id = p_class_id
        GROUP BY 
            ar.status
    ),
    total_possible AS (
        SELECT 
            sc.session_count * stc.student_count AS total
        FROM 
            session_counts sc, student_counts stc
    )
    SELECT 
        sc.session_count AS total_sessions,
        COALESCE((SELECT count FROM status_counts WHERE status = 'present'), 0) AS present_count,
        COALESCE((SELECT count FROM status_counts WHERE status = 'absent'), 0) AS absent_count,
        COALESCE((SELECT count FROM status_counts WHERE status = 'late'), 0) AS late_count,
        COALESCE((SELECT count FROM status_counts WHERE status = 'excused'), 0) AS excused_count,
        CASE 
            WHEN tp.total > 0 THEN 
                (COALESCE((SELECT count FROM status_counts WHERE status = 'present'), 0) + 
                 COALESCE((SELECT count FROM status_counts WHERE status = 'late'), 0) * 0.5 +
                 COALESCE((SELECT count FROM status_counts WHERE status = 'excused'), 0)) / tp.total * 100
            ELSE 0
        END AS average_attendance
    FROM 
        session_counts sc, 
        student_counts stc,
        total_possible tp;
END;
$$ LANGUAGE plpgsql;

-- Function to get attendance statistics for a student
CREATE OR REPLACE FUNCTION get_student_attendance_stats(
    p_class_id UUID,
    p_student_id UUID
)
RETURNS TABLE (
    total_sessions INT,
    present_count INT,
    absent_count INT,
    late_count INT,
    excused_count INT,
    attendance_percentage NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    WITH session_counts AS (
        SELECT COUNT(*) AS session_count
        FROM attendance_sessions
        WHERE class_id = p_class_id
    ),
    status_counts AS (
        SELECT 
            ar.status,
            COUNT(*) AS count
        FROM 
            attendance_records ar
        JOIN 
            attendance_sessions as_session ON ar.session_id = as_session.id
        WHERE 
            as_session.class_id = p_class_id
            AND ar.student_id = p_student_id
        GROUP BY 
            ar.status
    )
    SELECT 
        sc.session_count AS total_sessions,
        COALESCE((SELECT count FROM status_counts WHERE status = 'present'), 0) AS present_count,
        COALESCE((SELECT count FROM status_counts WHERE status = 'absent'), 0) AS absent_count,
        COALESCE((SELECT count FROM status_counts WHERE status = 'late'), 0) AS late_count,
        COALESCE((SELECT count FROM status_counts WHERE status = 'excused'), 0) AS excused_count,
        CASE 
            WHEN sc.session_count > 0 THEN 
                (COALESCE((SELECT count FROM status_counts WHERE status = 'present'), 0) + 
                 COALESCE((SELECT count FROM status_counts WHERE status = 'late'), 0) * 0.5 +
                 COALESCE((SELECT count FROM status_counts WHERE status = 'excused'), 0)) / sc.session_count * 100
            ELSE 0
        END AS attendance_percentage
    FROM 
        session_counts sc;
END;
$$ LANGUAGE plpgsql;

-- Function to delete user account and all related data
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

-- =============================================
-- STEP 4: Create Triggers
-- =============================================

-- Trigger for creating a user record when a new auth user is created
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
AFTER INSERT ON auth.users
FOR EACH ROW EXECUTE FUNCTION handle_new_user();

-- Trigger to update the updated_at timestamp for users
CREATE OR REPLACE FUNCTION update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_users_timestamp
BEFORE UPDATE ON users
FOR EACH ROW EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER update_classes_timestamp
BEFORE UPDATE ON classes
FOR EACH ROW EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER update_students_timestamp
BEFORE UPDATE ON students
FOR EACH ROW EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER update_attendance_sessions_timestamp
BEFORE UPDATE ON attendance_sessions
FOR EACH ROW EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER update_attendance_records_timestamp
BEFORE UPDATE ON attendance_records
FOR EACH ROW EXECUTE FUNCTION update_timestamp();

-- =============================================
-- STEP 5: Set up Row Level Security (RLS)
-- =============================================

-- Enable RLS on all tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE subjects ENABLE ROW LEVEL SECURITY;
ALTER TABLE courses ENABLE ROW LEVEL SECURITY;
ALTER TABLE classes ENABLE ROW LEVEL SECURITY;
ALTER TABLE students ENABLE ROW LEVEL SECURITY;
ALTER TABLE class_students ENABLE ROW LEVEL SECURITY;
ALTER TABLE attendance_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE attendance_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_feedback ENABLE ROW LEVEL SECURITY;

-- Users table policies
CREATE POLICY "Users can view their own profile" 
ON users FOR SELECT 
USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile" 
ON users FOR UPDATE 
USING (auth.uid() = id);

CREATE POLICY "System can insert new users" 
ON users FOR INSERT 
WITH CHECK (true);

CREATE POLICY "Users can delete their own profile" 
ON users FOR DELETE 
USING (auth.uid() = id);

-- Subjects table policies
CREATE POLICY "All authenticated users can view subjects" 
ON subjects FOR SELECT 
USING (auth.role() = 'authenticated');

CREATE POLICY "Admin users can manage subjects" 
ON subjects FOR ALL
USING (
    EXISTS (
        SELECT 1 FROM users
        WHERE users.id = auth.uid()
        AND users.role = 'admin'
    )
);

-- Courses table policies
CREATE POLICY "All authenticated users can view courses" 
ON courses FOR SELECT 
USING (auth.role() = 'authenticated');

CREATE POLICY "Admin users can manage courses" 
ON courses FOR ALL
USING (
    EXISTS (
        SELECT 1 FROM users
        WHERE users.id = auth.uid()
        AND users.role = 'admin'
    )
);

-- Classes table policies
CREATE POLICY "Teachers can view their own classes" 
ON classes FOR SELECT 
USING (
    teacher_id = auth.uid() OR 
    EXISTS (
        SELECT 1 FROM users
        WHERE users.id = auth.uid()
        AND users.role = 'admin'
    )
);

CREATE POLICY "Teachers can create their own classes" 
ON classes FOR INSERT 
WITH CHECK (
    teacher_id = auth.uid() OR 
    EXISTS (
        SELECT 1 FROM users
        WHERE users.id = auth.uid()
        AND users.role = 'admin'
    )
);

CREATE POLICY "Teachers can update their own classes" 
ON classes FOR UPDATE 
USING (
    teacher_id = auth.uid() OR 
    EXISTS (
        SELECT 1 FROM users
        WHERE users.id = auth.uid()
        AND users.role = 'admin'
    )
);

CREATE POLICY "Teachers can delete their own classes" 
ON classes FOR DELETE 
USING (
    teacher_id = auth.uid() OR 
    EXISTS (
        SELECT 1 FROM users
        WHERE users.id = auth.uid()
        AND users.role = 'admin'
    )
);

-- Students table policies
CREATE POLICY "All authenticated users can view students" 
ON students FOR SELECT 
USING (auth.role() = 'authenticated');

CREATE POLICY "All authenticated users can create students" 
ON students FOR INSERT 
WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Teachers can update students in their classes" 
ON students FOR UPDATE 
USING (
    EXISTS (
        SELECT 1 FROM class_students cs
        JOIN classes c ON cs.class_id = c.id
        WHERE cs.student_id = students.id
        AND c.teacher_id = auth.uid()
    ) OR 
    EXISTS (
        SELECT 1 FROM users
        WHERE users.id = auth.uid()
        AND users.role = 'admin'
    )
);

CREATE POLICY "Teachers can delete students in their classes" 
ON students FOR DELETE 
USING (
    EXISTS (
        SELECT 1 FROM class_students cs
        JOIN classes c ON cs.class_id = c.id
        WHERE cs.student_id = students.id
        AND c.teacher_id = auth.uid()
    ) OR 
    EXISTS (
        SELECT 1 FROM users
        WHERE users.id = auth.uid()
        AND users.role = 'admin'
    )
);

-- Class_students table policies
CREATE POLICY "Teachers can view class_students for their classes" 
ON class_students FOR SELECT 
USING (
    EXISTS (
        SELECT 1 FROM classes
        WHERE classes.id = class_students.class_id
        AND (
            classes.teacher_id = auth.uid() OR 
            EXISTS (
                SELECT 1 FROM users
                WHERE users.id = auth.uid()
                AND users.role = 'admin'
            )
        )
    )
);

CREATE POLICY "Teachers can add students to their classes" 
ON class_students FOR INSERT 
WITH CHECK (
    EXISTS (
        SELECT 1 FROM classes
        WHERE classes.id = class_students.class_id
        AND (
            classes.teacher_id = auth.uid() OR 
            EXISTS (
                SELECT 1 FROM users
                WHERE users.id = auth.uid()
                AND users.role = 'admin'
            )
        )
    )
);

CREATE POLICY "Teachers can remove students from their classes" 
ON class_students FOR DELETE 
USING (
    EXISTS (
        SELECT 1 FROM classes
        WHERE classes.id = class_students.class_id
        AND (
            classes.teacher_id = auth.uid() OR 
            EXISTS (
                SELECT 1 FROM users
                WHERE users.id = auth.uid()
                AND users.role = 'admin'
            )
        )
    )
);

-- Attendance_sessions table policies
CREATE POLICY "Teachers can view attendance_sessions for their classes" 
ON attendance_sessions FOR SELECT 
USING (
    EXISTS (
        SELECT 1 FROM classes
        WHERE classes.id = attendance_sessions.class_id
        AND (
            classes.teacher_id = auth.uid() OR 
            EXISTS (
                SELECT 1 FROM users
                WHERE users.id = auth.uid()
                AND users.role = 'admin'
            )
        )
    )
);

CREATE POLICY "Teachers can create attendance_sessions for their classes" 
ON attendance_sessions FOR INSERT 
WITH CHECK (
    EXISTS (
        SELECT 1 FROM classes
        WHERE classes.id = attendance_sessions.class_id
        AND (
            classes.teacher_id = auth.uid() OR 
            EXISTS (
                SELECT 1 FROM users
                WHERE users.id = auth.uid()
                AND users.role = 'admin'
            )
        )
    )
);

CREATE POLICY "Teachers can update attendance_sessions for their classes" 
ON attendance_sessions FOR UPDATE 
USING (
    EXISTS (
        SELECT 1 FROM classes
        WHERE classes.id = attendance_sessions.class_id
        AND (
            classes.teacher_id = auth.uid() OR 
            EXISTS (
                SELECT 1 FROM users
                WHERE users.id = auth.uid()
                AND users.role = 'admin'
            )
        )
    )
);

CREATE POLICY "Teachers can delete attendance_sessions for their classes" 
ON attendance_sessions FOR DELETE 
USING (
    EXISTS (
        SELECT 1 FROM classes
        WHERE classes.id = attendance_sessions.class_id
        AND (
            classes.teacher_id = auth.uid() OR 
            EXISTS (
                SELECT 1 FROM users
                WHERE users.id = auth.uid()
                AND users.role = 'admin'
            )
        )
    )
);

-- Attendance_records table policies
CREATE POLICY "Teachers can view attendance_records for their classes" 
ON attendance_records FOR SELECT 
USING (
    EXISTS (
        SELECT 1 FROM attendance_sessions
        JOIN classes ON classes.id = attendance_sessions.class_id
        WHERE attendance_sessions.id = attendance_records.session_id
        AND (
            classes.teacher_id = auth.uid() OR 
            EXISTS (
                SELECT 1 FROM users
                WHERE users.id = auth.uid()
                AND users.role = 'admin'
            )
        )
    )
);

CREATE POLICY "Teachers can create attendance_records for their classes" 
ON attendance_records FOR INSERT 
WITH CHECK (
    EXISTS (
        SELECT 1 FROM attendance_sessions
        JOIN classes ON classes.id = attendance_sessions.class_id
        WHERE attendance_sessions.id = attendance_records.session_id
        AND (
            classes.teacher_id = auth.uid() OR 
            EXISTS (
                SELECT 1 FROM users
                WHERE users.id = auth.uid()
                AND users.role = 'admin'
            )
        )
    )
);

CREATE POLICY "Teachers can update attendance_records for their classes" 
ON attendance_records FOR UPDATE 
USING (
    EXISTS (
        SELECT 1 FROM attendance_sessions
        JOIN classes ON classes.id = attendance_sessions.class_id
        WHERE attendance_sessions.id = attendance_records.session_id
        AND (
            classes.teacher_id = auth.uid() OR 
            EXISTS (
                SELECT 1 FROM users
                WHERE users.id = auth.uid()
                AND users.role = 'admin'
            )
        )
    )
);

CREATE POLICY "Teachers can delete attendance_records for their classes" 
ON attendance_records FOR DELETE 
USING (
    EXISTS (
        SELECT 1 FROM attendance_sessions
        JOIN classes ON classes.id = attendance_sessions.class_id
        WHERE attendance_sessions.id = attendance_records.session_id
        AND (
            classes.teacher_id = auth.uid() OR 
            EXISTS (
                SELECT 1 FROM users
                WHERE users.id = auth.uid()
                AND users.role = 'admin'
            )
        )
    )
);

-- User feedback policies
CREATE POLICY "Users can submit their own feedback" 
ON user_feedback FOR INSERT 
WITH CHECK (auth.uid()::text = user_id::text);

CREATE POLICY "Users can view their own feedback" 
ON user_feedback FOR SELECT 
USING (auth.uid()::text = user_id::text);

CREATE POLICY "Admins can view all feedback" 
ON user_feedback FOR SELECT 
USING (
    EXISTS (
        SELECT 1 FROM users
        WHERE users.id = auth.uid()
        AND users.role = 'admin'
    )
);

-- =============================================
-- STEP 6: Set up Storage Buckets
-- =============================================

-- Create profile_images bucket
INSERT INTO storage.buckets (id, name, public)
VALUES ('profile_images', 'Profile Images', true)
ON CONFLICT (id) DO NOTHING;

-- Create class_attachments bucket
INSERT INTO storage.buckets (id, name, public)
VALUES ('class_attachments', 'Class Attachments', false)
ON CONFLICT (id) DO NOTHING;

-- Create attendance_reports bucket
INSERT INTO storage.buckets (id, name, public)
VALUES ('attendance_reports', 'Attendance Reports', false)
ON CONFLICT (id) DO NOTHING;

-- Enable RLS on storage.objects
ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

-- Profile Images bucket policies
CREATE POLICY "Public profiles are viewable by everyone" 
ON storage.objects FOR SELECT
USING (bucket_id = 'profile_images');

CREATE POLICY "Users can upload their own profile image" 
ON storage.objects FOR INSERT 
WITH CHECK (
    bucket_id = 'profile_images' AND 
    auth.uid()::text = (storage.foldername(name))[1]
);

CREATE POLICY "Users can update their own profile image" 
ON storage.objects FOR UPDATE
USING (
    bucket_id = 'profile_images' AND 
    auth.uid()::text = (storage.foldername(name))[1]
);

CREATE POLICY "Users can delete their own profile image" 
ON storage.objects FOR DELETE
USING (
    bucket_id = 'profile_images' AND 
    auth.uid()::text = (storage.foldername(name))[1]
);

-- Class Attachments bucket policies
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

-- Attendance Reports bucket policies
CREATE POLICY "Teachers can view their attendance reports" 
ON storage.objects FOR SELECT
USING (
    bucket_id = 'attendance_reports' AND 
    EXISTS (
        SELECT 1 FROM classes
        WHERE classes.id::text = (storage.foldername(name))[1]
        AND classes.teacher_id = auth.uid()
    )
);

CREATE POLICY "Teachers can upload their attendance reports" 
ON storage.objects FOR INSERT
WITH CHECK (
    bucket_id = 'attendance_reports' AND 
    EXISTS (
        SELECT 1 FROM classes
        WHERE classes.id::text = (storage.foldername(name))[1]
        AND classes.teacher_id = auth.uid()
    )
);

CREATE POLICY "Teachers can update their attendance reports" 
ON storage.objects FOR UPDATE
USING (
    bucket_id = 'attendance_reports' AND 
    EXISTS (
        SELECT 1 FROM classes
        WHERE classes.id::text = (storage.foldername(name))[1]
        AND classes.teacher_id = auth.uid()
    )
);

CREATE POLICY "Teachers can delete their attendance reports" 
ON storage.objects FOR DELETE
USING (
    bucket_id = 'attendance_reports' AND 
    EXISTS (
        SELECT 1 FROM classes
        WHERE classes.id::text = (storage.foldername(name))[1]
        AND classes.teacher_id = auth.uid()
    )
);
-- Add image_url column to students table
ALTER TABLE students 
ADD COLUMN IF NOT EXISTS image_url TEXT;

-- Create a storage bucket for student images if it doesn't exist
INSERT INTO storage.buckets (id, name, public)
VALUES ('student_images', 'Student Images', true)
ON CONFLICT (id) DO NOTHING;

-- Add storage policy for student images
CREATE POLICY "Student images are viewable by authenticated users" 
ON storage.objects FOR SELECT
USING (bucket_id = 'student_images' AND auth.role() = 'authenticated');

CREATE POLICY "Teachers can upload student images" 
ON storage.objects FOR INSERT 
WITH CHECK (bucket_id = 'student_images' AND auth.role() = 'authenticated');

CREATE POLICY "Teachers can update student images" 
ON storage.objects FOR UPDATE
USING (bucket_id = 'student_images' AND auth.role() = 'authenticated');

CREATE POLICY "Teachers can delete student images" 
ON storage.objects FOR DELETE
USING (bucket_id = 'student_images' AND auth.role() = 'authenticated');

-- Run this SQL in your Supabase SQL editor if the column doesn't exist
ALTER TABLE attendance_sessions ADD COLUMN IF NOT EXISTS status TEXT DEFAULT 'open' CHECK (status IN ('open', 'closed'));



-- =============================================
-- STEP 7: Insert Sample Data
-- =============================================

-- Add unique constraints before using ON CONFLICT
-- ALTER TABLE subjects ADD CONSTRAINT IF NOT EXISTS subjects_name_key UNIQUE (name);
-- ALTER TABLE courses ADD CONSTRAINT IF NOT EXISTS courses_name_key UNIQUE (name);


-- -- Insert sample subjects
-- INSERT INTO subjects (name, code)
-- VALUES 
--     ('Mathematics', 'MATH101'),
--     ('Physics', 'PHYS101'),
--     ('Computer Science', 'CS101'),
--     ('English', 'ENG101'),
--     ('Chemistry', 'CHEM101')
-- ON CONFLICT (name) DO NOTHING;

-- -- Insert sample courses
-- INSERT INTO courses (name, code)
-- VALUES 
--     ('Computer Science', 'CS'),
--     ('Electrical Engineering', 'EE'),
--     ('Mechanical Engineering', 'ME'),
--     ('Civil Engineering', 'CE'),
--     ('Business Administration', 'BA')
-- ON CONFLICT (name) DO NOTHING;

-- =============================================
-- STEP 8: Create Indexes for Performance
-- =============================================

-- Indexes for users table
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);

-- Indexes for classes table
CREATE INDEX IF NOT EXISTS idx_classes_teacher_id ON classes(teacher_id);
CREATE INDEX IF NOT EXISTS idx_classes_subject_id ON classes(subject_id);
CREATE INDEX IF NOT EXISTS idx_classes_course_id ON classes(course_id);

-- Indexes for students table
CREATE INDEX IF NOT EXISTS idx_students_roll_number ON students(roll_number);

-- Indexes for class_students table
CREATE INDEX IF NOT EXISTS idx_class_students_class_id ON class_students(class_id);
CREATE INDEX IF NOT EXISTS idx_class_students_student_id ON class_students(student_id);

-- Indexes for attendance_sessions table
CREATE INDEX IF NOT EXISTS idx_attendance_sessions_class_id ON attendance_sessions(class_id);
CREATE INDEX IF NOT EXISTS idx_attendance_sessions_date ON attendance_sessions(date);
CREATE INDEX IF NOT EXISTS idx_attendance_sessions_created_by ON attendance_sessions(created_by);

-- Indexes for attendance_records table
CREATE INDEX IF NOT EXISTS idx_attendance_records_session_id ON attendance_records(session_id);
CREATE INDEX IF NOT EXISTS idx_attendance_records_student_id ON attendance_records(student_id);
CREATE INDEX IF NOT EXISTS idx_attendance_records_status ON attendance_records(status);

-- =============================================
-- STEP 9: Create Additional Utility Functions
-- =============================================

-- Function to get all students in a class
CREATE OR REPLACE FUNCTION get_class_students(p_class_id UUID)
RETURNS TABLE (
    student_id UUID,
    student_name TEXT,
    roll_number TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        s.id AS student_id,
        s.name AS student_name,
        s.roll_number
    FROM 
        students s
    JOIN 
        class_students cs ON s.id = cs.student_id
    WHERE 
        cs.class_id = p_class_id
    ORDER BY 
        s.roll_number;
END;
$$ LANGUAGE plpgsql;

-- Function to get attendance for a specific session
CREATE OR REPLACE FUNCTION get_session_attendance(p_session_id UUID)
RETURNS TABLE (
    student_id UUID,
    student_name TEXT,
    roll_number TEXT,
    status TEXT,
    remarks TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        s.id AS student_id,
        s.name AS student_name,
        s.roll_number,
        COALESCE(ar.status, 'unmarked') AS status,
        ar.remarks
    FROM 
        attendance_sessions ats
    JOIN 
        class_students cs ON ats.class_id = cs.class_id
    JOIN 
        students s ON cs.student_id = s.id
    LEFT JOIN 
        attendance_records ar ON ar.session_id = ats.id AND ar.student_id = s.id
    WHERE 
        ats.id = p_session_id
    ORDER BY 
        s.roll_number;
END;
$$ LANGUAGE plpgsql;

-- Function to get attendance report for a class
CREATE OR REPLACE FUNCTION get_class_attendance_report(
    p_class_id UUID,
    p_start_date DATE,
    p_end_date DATE
)
RETURNS TABLE (
    student_id UUID,
    student_name TEXT,
    roll_number TEXT,
    present_count INT,
    absent_count INT,
    late_count INT,
    excused_count INT,
    total_sessions INT,
    attendance_percentage NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    WITH sessions AS (
        SELECT id
        FROM attendance_sessions
        WHERE class_id = p_class_id
        AND date BETWEEN p_start_date AND p_end_date
    ),
    session_count AS (
        SELECT COUNT(*) AS count FROM sessions
    ),
    student_records AS (
        SELECT 
            s.id AS student_id,
            s.name AS student_name,
            s.roll_number,
            COUNT(CASE WHEN ar.status = 'present' THEN 1 END) AS present_count,
            COUNT(CASE WHEN ar.status = 'absent' THEN 1 END) AS absent_count,
            COUNT(CASE WHEN ar.status = 'late' THEN 1 END) AS late_count,
            COUNT(CASE WHEN ar.status = 'excused' THEN 1 END) AS excused_count
        FROM 
            students s
        JOIN 
            class_students cs ON s.id = cs.student_id
        LEFT JOIN 
            sessions sess ON true
        LEFT JOIN 
            attendance_records ar ON ar.session_id = sess.id AND ar.student_id = s.id
        WHERE 
            cs.class_id = p_class_id
        GROUP BY 
            s.id, s.name, s.roll_number
    )
    SELECT 
        sr.student_id,
        sr.student_name,
        sr.roll_number,
        sr.present_count,
        sr.absent_count,
        sr.late_count,
        sr.excused_count,
        sc.count AS total_sessions,
        CASE 
            WHEN sc.count > 0 THEN 
                (sr.present_count + sr.late_count * 0.5 + sr.excused_count) / sc.count * 100
            ELSE 0
        END AS attendance_percentage
    FROM 
        student_records sr,
        session_count sc
    ORDER BY 
        sr.roll_number;
END;
$$ LANGUAGE plpgsql;

-- Function to bulk submit attendance
CREATE OR REPLACE FUNCTION bulk_submit_attendance(
    p_session_id UUID,
    p_attendance_data JSONB
)
RETURNS SETOF UUID AS $$
DECLARE
    student_record JSONB;
    record_id UUID;
BEGIN
    FOR student_record IN SELECT jsonb_array_elements(p_attendance_data)
    LOOP
        SELECT submit_attendance(
            p_session_id,
            (student_record->>'student_id')::UUID,
            student_record->>'status',
            student_record->>'remarks'
        ) INTO record_id;
        
        RETURN NEXT record_id;
    END LOOP;
    
    RETURN;
END;
$$ LANGUAGE plpgsql;

-- =============================================
-- STEP 10: Create Audit Logging
-- =============================================

-- Create audit log table
CREATE TABLE IF NOT EXISTS audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID,
    action TEXT NOT NULL,
    table_name TEXT NOT NULL,
    record_id TEXT,
    old_data JSONB,
    new_data JSONB,
    ip_address TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Function to log changes
CREATE OR REPLACE FUNCTION log_audit()
RETURNS TRIGGER AS $$
DECLARE
    audit_row audit_logs;
    excluded_cols TEXT[] = ARRAY[]::TEXT[];
BEGIN
    audit_row = ROW(
        uuid_generate_v4(),
        auth.uid(),
        CASE
            WHEN TG_OP = 'INSERT' THEN 'INSERT'
            WHEN TG_OP = 'UPDATE' THEN 'UPDATE'
            WHEN TG_OP = 'DELETE' THEN 'DELETE'
            ELSE TG_OP
        END,
        TG_TABLE_NAME,
        CASE
            WHEN TG_OP = 'INSERT' THEN NEW.id::TEXT
            WHEN TG_OP = 'UPDATE' THEN NEW.id::TEXT
            WHEN TG_OP = 'DELETE' THEN OLD.id::TEXT
            ELSE NULL
        END,
        CASE
            WHEN TG_OP = 'INSERT' THEN NULL
            WHEN TG_OP = 'UPDATE' THEN to_jsonb(OLD)
            WHEN TG_OP = 'DELETE' THEN to_jsonb(OLD)
            ELSE NULL
        END,
        CASE
            WHEN TG_OP = 'INSERT' THEN to_jsonb(NEW)
            WHEN TG_OP = 'UPDATE' THEN to_jsonb(NEW)
            WHEN TG_OP = 'DELETE' THEN NULL
            ELSE NULL
        END,
        NULL,
        NOW()
    );

    INSERT INTO audit_logs VALUES (audit_row.*);
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Add audit triggers to important tables
CREATE TRIGGER audit_classes_changes
AFTER INSERT OR UPDATE OR DELETE ON classes
FOR EACH ROW EXECUTE FUNCTION log_audit();

CREATE TRIGGER audit_attendance_sessions_changes
AFTER INSERT OR UPDATE OR DELETE ON attendance_sessions
FOR EACH ROW EXECUTE FUNCTION log_audit();

CREATE TRIGGER audit_attendance_records_changes
AFTER INSERT OR UPDATE OR DELETE ON attendance_records
FOR EACH ROW EXECUTE FUNCTION log_audit();

-- =============================================
-- STEP 11: Create API for Mobile App
-- =============================================

-- Function to get teacher dashboard data
CREATE OR REPLACE FUNCTION get_teacher_dashboard(p_teacher_id UUID)
RETURNS JSONB AS $$
DECLARE
    result JSONB;
BEGIN
    WITH teacher_classes AS (
        SELECT id FROM classes WHERE teacher_id = p_teacher_id
    ),
    class_count AS (
        SELECT COUNT(*) AS count FROM teacher_classes
    ),
    student_count AS (
        SELECT COUNT(DISTINCT cs.student_id) AS count
        FROM class_students cs
        WHERE cs.class_id IN (SELECT id FROM teacher_classes)
    ),
    session_count AS (
        SELECT COUNT(*) AS count
        FROM attendance_sessions
        WHERE class_id IN (SELECT id FROM teacher_classes)
    ),
    recent_sessions AS (
        SELECT 
            ats.id,
            ats.date,
            c.id AS class_id,
            s.name AS subject_name,
            co.name AS course_name,
            c.semester,
            c.section,
            (
                SELECT COUNT(*)
                FROM attendance_records ar
                WHERE ar.session_id = ats.id AND ar.status = 'present'
            ) AS present_count,
            (
                SELECT COUNT(*)
                FROM class_students cs
                WHERE cs.class_id = c.id
            ) AS total_students
        FROM 
            attendance_sessions ats
        JOIN 
            classes c ON ats.class_id = c.id
        JOIN 
            subjects s ON c.subject_id = s.id
        JOIN 
            courses co ON c.course_id = co.id
        WHERE 
            c.teacher_id = p_teacher_id
        ORDER BY 
            ats.date DESC
        LIMIT 5
    )
    SELECT 
        jsonb_build_object(
            'class_count', (SELECT count FROM class_count),
            'student_count', (SELECT count FROM student_count),
            'session_count', (SELECT count FROM session_count),
            'recent_sessions', (
                SELECT jsonb_agg(
                    jsonb_build_object(
                        'id', id,
                        'date', date,
                        'class_id', class_id,
                        'subject_name', subject_name,
                        'course_name', course_name,
                        'semester', semester,
                        'section', section,
                        'present_count', present_count,
                        'total_students', total_students,
                        'attendance_percentage', 
                            CASE 
                                WHEN total_students > 0 THEN 
                                    (present_count::NUMERIC / total_students) * 100
                                ELSE 0
                            END
                    )
                )
                FROM recent_sessions
            )
        ) INTO result;
    
    RETURN result;
END;
$$ LANGUAGE plpgsql;

-- =============================================
-- STEP 12: Commit all changes
-- =============================================
COMMIT;

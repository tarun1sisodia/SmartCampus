-- =============================================
-- Attendance Management System Database Setup
-- =============================================
-- This script sets up the complete database schema for the attendance management system
-- including tables, relationships, indexes, and row level security policies.
-- Run this in the Supabase SQL Editor to initialize your database.

-- =============================================
-- STEP 1: Drop existing tables (if needed for clean setup)
-- =============================================
BEGIN;

-- Drop tables if they exist (in reverse order of dependencies)
DROP TABLE IF EXISTS attendance_records CASCADE;
DROP TABLE IF EXISTS attendance_sessions CASCADE;
DROP TABLE IF EXISTS class_students CASCADE;
DROP TABLE IF EXISTS classes CASCADE;
DROP TABLE IF EXISTS students CASCADE;
DROP TABLE IF EXISTS subjects CASCADE;
DROP TABLE IF EXISTS courses CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- =============================================
-- STEP 2: Create tables
-- =============================================

-- Users table (extends Supabase auth.users)
CREATE TABLE users (
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
CREATE TABLE subjects (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    code TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ
);

-- Courses table
CREATE TABLE courses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    code TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ
);

-- Students table
CREATE TABLE students (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    roll_number TEXT NOT NULL UNIQUE,
    email TEXT,
    phone TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ
);

-- Classes table
CREATE TABLE classes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    teacher_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    subject_id UUID NOT NULL REFERENCES subjects(id) ON DELETE CASCADE,
    course_id UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
    year INTEGER NOT NULL CHECK (year BETWEEN 1 AND 5),
    section TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ
);

-- Class-Students junction table
CREATE TABLE class_students (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    class_id UUID NOT NULL REFERENCES classes(id) ON DELETE CASCADE,
    student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    UNIQUE(class_id, student_id)
);

-- Attendance Sessions table
CREATE TABLE attendance_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
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
CREATE TABLE attendance_records (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID NOT NULL REFERENCES attendance_sessions(id) ON DELETE CASCADE,
    student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
    status TEXT NOT NULL CHECK (status IN ('present', 'absent', 'late')),
    remarks TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    UNIQUE(session_id, student_id)
);

-- =============================================
-- STEP 3: Create indexes for performance
-- =============================================

-- Indexes for users table
CREATE INDEX idx_users_email ON users(email);

-- Indexes for classes table
CREATE INDEX idx_classes_teacher_id ON classes(teacher_id);
CREATE INDEX idx_classes_subject_id ON classes(subject_id);
CREATE INDEX idx_classes_course_id ON classes(course_id);

-- Indexes for class_students table
CREATE INDEX idx_class_students_class_id ON class_students(class_id);
CREATE INDEX idx_class_students_student_id ON class_students(student_id);

-- Indexes for attendance_sessions table
CREATE INDEX idx_attendance_sessions_class_id ON attendance_sessions(class_id);
CREATE INDEX idx_attendance_sessions_date ON attendance_sessions(date);
CREATE INDEX idx_attendance_sessions_created_by ON attendance_sessions(created_by);

-- Indexes for attendance_records table
CREATE INDEX idx_attendance_records_session_id ON attendance_records(session_id);
CREATE INDEX idx_attendance_records_student_id ON attendance_records(student_id);
CREATE INDEX idx_attendance_records_status ON attendance_records(status);

-- =============================================
-- STEP 4: Set up Row Level Security (RLS)
-- =============================================

-- Enable RLS on all tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE subjects ENABLE ROW LEVEL SECURITY;
ALTER TABLE courses ENABLE ROW LEVEL SECURITY;
ALTER TABLE students ENABLE ROW LEVEL SECURITY;
ALTER TABLE classes ENABLE ROW LEVEL SECURITY;
ALTER TABLE class_students ENABLE ROW LEVEL SECURITY;
ALTER TABLE attendance_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE attendance_records ENABLE ROW LEVEL SECURITY;

-- Create policies for users table
CREATE POLICY "Users can view their own profile" 
ON users FOR SELECT 
USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile" 
ON users FOR UPDATE 
USING (auth.uid() = id);

-- Create policies for subjects table (all authenticated users can view)
CREATE POLICY "All users can view subjects" 
ON subjects FOR SELECT 
USING (auth.role() = 'authenticated');

-- Create policies for courses table (all authenticated users can view)
CREATE POLICY "All users can view courses" 
ON courses FOR SELECT 
USING (auth.role() = 'authenticated');

-- Create policies for students table
CREATE POLICY "All users can view students" 
ON students FOR SELECT 
USING (auth.role() = 'authenticated');

CREATE POLICY "All users can create students" 
ON students FOR INSERT 
WITH CHECK (auth.role() = 'authenticated');

-- Create policies for classes table
CREATE POLICY "Teachers can view their own classes" 
ON classes FOR SELECT 
USING (teacher_id = auth.uid() OR EXISTS (
    SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin'
));

CREATE POLICY "Teachers can create their own classes" 
ON classes FOR INSERT 
WITH CHECK (teacher_id = auth.uid() OR EXISTS (
    SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin'
));

CREATE POLICY "Teachers can update their own classes" 
ON classes FOR UPDATE 
USING (teacher_id = auth.uid() OR EXISTS (
    SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin'
));

CREATE POLICY "Teachers can delete their own classes" 
ON classes FOR DELETE 
USING (teacher_id = auth.uid() OR EXISTS (
    SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin'
));

-- Create policies for class_students table
CREATE POLICY "Teachers can view class_students for their classes" 
ON class_students FOR SELECT 
USING (EXISTS (
    SELECT 1 FROM classes 
    WHERE classes.id = class_students.class_id 
    AND (classes.teacher_id = auth.uid() OR EXISTS (
        SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin'
    ))
));

CREATE POLICY "Teachers can add students to their classes" 
ON class_students FOR INSERT 
WITH CHECK (EXISTS (
    SELECT 1 FROM classes 
    WHERE classes.id = class_students.class_id 
    AND (classes.teacher_id = auth.uid() OR EXISTS (
        SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin'
    ))
));

CREATE POLICY "Teachers can remove students from their classes" 
ON class_students FOR DELETE 
USING (EXISTS (
    SELECT 1 FROM classes 
    WHERE classes.id = class_students.class_id 
    AND (classes.teacher_id = auth.uid() OR EXISTS (
        SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin'
    ))
));

-- Create policies for attendance_sessions table
CREATE POLICY "Teachers can view attendance_sessions for their classes" 
ON attendance_sessions FOR SELECT 
USING (EXISTS (
    SELECT 1 FROM classes 
    WHERE classes.id = attendance_sessions.class_id 
    AND (classes.teacher_id = auth.uid() OR EXISTS (
        SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin'
    ))
));

CREATE POLICY "Teachers can create attendance_sessions for their classes" 
ON attendance_sessions FOR INSERT 
WITH CHECK (EXISTS (
    SELECT 1 FROM classes 
    WHERE classes.id = attendance_sessions.class_id 
    AND (classes.teacher_id = auth.uid() OR EXISTS (
        SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin'
    ))
));

CREATE POLICY "Teachers can update attendance_sessions for their classes" 
ON attendance_sessions FOR UPDATE 
USING (EXISTS (
    SELECT 1 FROM classes 
    WHERE classes.id = attendance_sessions.class_id 
    AND (classes.teacher_id = auth.uid() OR EXISTS (
        SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin'
    ))
));

CREATE POLICY "Teachers can delete attendance_sessions for their classes" 
ON attendance_sessions FOR DELETE 
USING (EXISTS (
    SELECT 1 FROM classes 
    WHERE classes.id = attendance_sessions.class_id 
    AND (classes.teacher_id = auth.uid() OR EXISTS (
        SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin'
    ))
));

-- Create policies for attendance_records table
CREATE POLICY "Teachers can view attendance_records for their classes" 
ON attendance_records FOR SELECT 
USING (EXISTS (
    SELECT 1 FROM attendance_sessions 
    JOIN classes ON classes.id = attendance_sessions.class_id
    WHERE attendance_sessions.id = attendance_records.session_id 
    AND (classes.teacher_id = auth.uid() OR EXISTS (
        SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin'
    ))
));

CREATE POLICY "Teachers can create attendance_records for their classes" 
ON attendance_records FOR INSERT 
WITH CHECK (EXISTS (
    SELECT 1 FROM attendance_sessions 
    JOIN classes ON classes.id = attendance_sessions.class_id
    WHERE attendance_sessions.id = attendance_records.session_id 
    AND (classes.teacher_id = auth.uid() OR EXISTS (
        SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin'
    ))
));

CREATE POLICY "Teachers can update attendance_records for their classes" 
ON attendance_records FOR UPDATE 
USING (EXISTS (
    SELECT 1 FROM attendance_sessions 
    JOIN classes ON classes.id = attendance_sessions.class_id
    WHERE attendance_sessions.id = attendance_records.session_id 
    AND (classes.teacher_id = auth.uid() OR EXISTS (
        SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin'
    ))
));

CREATE POLICY "Teachers can delete attendance_records for their classes" 
ON attendance_records FOR DELETE 
USING (EXISTS (
    SELECT 1 FROM attendance_sessions 
    JOIN classes ON classes.id = attendance_sessions.class_id
    WHERE attendance_sessions.id = attendance_records.session_id 
    AND (classes.teacher_id = auth.uid() OR EXISTS (
        SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin'
    ))
));

-- =============================================
-- STEP 5: Create functions and triggers
-- =============================================

-- Function to update the updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create triggers for all tables to update the updated_at column
CREATE TRIGGER update_users_updated_at
BEFORE UPDATE ON users
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_subjects_updated_at
BEFORE UPDATE ON subjects
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_courses_updated_at
BEFORE UPDATE ON courses
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_students_updated_at
BEFORE UPDATE ON students
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_classes_updated_at
BEFORE UPDATE ON classes
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_class_students_updated_at
BEFORE UPDATE ON class_students
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_attendance_sessions_updated_at
BEFORE UPDATE ON attendance_sessions
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_attendance_records_updated_at
BEFORE UPDATE ON attendance_records
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Function to handle user creation
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO users (id, name, email, created_at)
    VALUES (NEW.id, COALESCE(NEW.raw_user_meta_data->>'name', 'New User'), NEW.email, NOW());
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to automatically create a user record when a new auth user is created
CREATE TRIGGER on_auth_user_created
AFTER INSERT ON auth.users
FOR EACH ROW EXECUTE FUNCTION handle_new_user();

-- Function to get attendance statistics for a class
CREATE OR REPLACE FUNCTION get_class_attendance_stats(class_id UUID)
RETURNS TABLE (
    total_sessions BIGINT,
    total_students BIGINT,
    present_count BIGINT,
    absent_count BIGINT,
    late_count BIGINT,
    average_attendance NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    WITH session_counts AS (
        SELECT COUNT(*) AS session_count
        FROM attendance_sessions
        WHERE class_id = $1
    ),
    student_counts AS (
        SELECT COUNT(*) AS student_count
        FROM class_students
        WHERE class_id = $1
    ),
    status_counts AS (
        SELECT 
            ar.status,
            COUNT(*) AS count
        FROM 
            attendance_records ar
        JOIN 
            attendance_sessions ats ON ar.session_id = ats.id
        WHERE 
            ats.class_id = $1
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
        stc.student_count AS total_students,
        COALESCE((SELECT count FROM status_counts WHERE status = 'present'), 0) AS present_count,
        COALESCE((SELECT count FROM status_counts WHERE status = 'absent'), 0) AS absent_count,
        COALESCE((SELECT count FROM status_counts WHERE status = 'late'), 0) AS late_count,
        CASE 
            WHEN tp.total > 0 THEN 
                (COALESCE((SELECT count FROM status_counts WHERE status = 'present'), 0) + 
                 COALESCE((SELECT count FROM status_counts WHERE status = 'late'), 0) * 0.5) / tp.total * 100
            ELSE 0
        END AS average_attendance
    FROM 
        session_counts sc, 
        student_counts stc,
        total_possible tp;
END;
$$ LANGUAGE plpgsql;

-- Function to get attendance statistics for a student in a class
CREATE OR REPLACE FUNCTION get_student_attendance_stats(class_id UUID, student_id UUID)
RETURNS TABLE (
    total_sessions BIGINT,
    present_count BIGINT,
    absent_count BIGINT,
    late_count BIGINT,
    attendance_percentage NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    WITH session_counts AS (
        SELECT COUNT(*) AS session_count
        FROM attendance_sessions
        WHERE class_id = $1
    ),
    status_counts AS (
        SELECT 
            ar.status,
            COUNT(*) AS count
        FROM 
            attendance_records ar
        JOIN 
            attendance_sessions ats ON ar.session_id = ats.id
        WHERE 
            ats.class_id = $1 AND ar.student_id = $2
        GROUP BY 
            ar.status
    )
    SELECT 
        sc.session_count AS total_sessions,
        COALESCE((SELECT count FROM status_counts WHERE status = 'present'), 0) AS present_count,
        COALESCE((SELECT count FROM status_counts WHERE status = 'absent'), 0) AS absent_count,
        COALESCE((SELECT count FROM status_counts WHERE status = 'late'), 0) AS late_count,
        CASE 
            WHEN sc.session_count > 0 THEN 
                (COALESCE((SELECT count FROM status_counts WHERE status = 'present'), 0) + 
                 COALESCE((SELECT count FROM status_counts WHERE status = 'late'), 0) * 0.5) / sc.session_count * 100
            ELSE 0
        END AS attendance_percentage
    FROM 
        session_counts sc;
END;
$$ LANGUAGE plpgsql;

-- Function to get attendance statistics for a date range
CREATE OR REPLACE FUNCTION get_attendance_stats_for_date_range(
    class_id UUID, 
    start_date DATE, 
    end_date DATE
)
RETURNS TABLE (
    total_sessions BIGINT,
    present_count BIGINT,
    absent_count BIGINT,
    late_count BIGINT,
    average_attendance NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    WITH session_counts AS (
        SELECT COUNT(*) AS session_count
        FROM attendance_sessions
        WHERE class_id = $1 AND date >= $2 AND date <= $3
    ),
    student_counts AS (
        SELECT COUNT(*) AS student_count
        FROM class_students
        WHERE class_id = $1
    ),
    status_counts AS (
        SELECT 
            ar.status,
            COUNT(*) AS count
        FROM 
            attendance_records ar
        JOIN 
            attendance_sessions ats ON ar.session_id = ats.id
        WHERE 
            ats.class_id = $1 AND ats.date >= $2 AND ats.date <= $3
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
        CASE 
            WHEN tp.total > 0 THEN 
                (COALESCE((SELECT count FROM status_counts WHERE status = 'present'), 0) + 
                 COALESCE((SELECT count FROM status_counts WHERE status = 'late'), 0) * 0.5) / tp.total * 100
            ELSE 0
        END AS average_attendance
    FROM 
        session_counts sc, 
        student_counts stc,
        total_possible tp;
END;
$$ LANGUAGE plpgsql;

-- Function to safely add a student to a class with error handling
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
    -- Check if class exists
    SELECT EXISTS(SELECT 1 FROM classes WHERE id = p_class_id) INTO v_exists;
    IF NOT v_exists THEN
        RAISE EXCEPTION 'Class with ID % does not exist', p_class_id;
    END IF;
    
    -- Check if student with roll number already exists
    SELECT id FROM students WHERE roll_number = p_roll_number INTO v_student_id;
    
    IF v_student_id IS NULL THEN
        -- Create new student
        INSERT INTO students (name, roll_number, created_at)
        VALUES (p_student_name, p_roll_number, NOW())
        RETURNING id INTO v_student_id;
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

-- Function to safely create an attendance session with error handling
CREATE OR REPLACE FUNCTION create_attendance_session(
    p_class_id UUID,
    p_date DATE,
    p_start_time TEXT,
    p_end_time TEXT,
    p_created_by UUID
)
RETURNS UUID AS $$
DECLARE
    v_session_id UUID;
    v_exists BOOLEAN;
BEGIN
    -- Check if class exists
    SELECT EXISTS(SELECT 1 FROM classes WHERE id = p_class_id) INTO v_exists;
    IF NOT v_exists THEN
        RAISE EXCEPTION 'Class with ID % does not exist', p_class_id;
    END IF;
    
    -- Check if session for this date already exists
    SELECT EXISTS(
        SELECT 1 FROM attendance_sessions 
        WHERE class_id = p_class_id AND date = p_date
    ) INTO v_exists;
    
    IF v_exists THEN
        RAISE EXCEPTION 'Attendance session for class % on date % already exists', p_class_id, p_date;
    END IF;
    
    -- Create attendance session
    INSERT INTO attendance_sessions (class_id, date, start_time, end_time, created_by, created_at)
    VALUES (p_class_id, p_date, p_start_time, p_end_time, p_created_by, NOW())
    RETURNING id INTO v_session_id;
    
    RETURN v_session_id;
EXCEPTION
    WHEN unique_violation THEN
        RAISE EXCEPTION 'Attendance session for this class and date already exists';
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error creating attendance session: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- Function to safely submit attendance with error handling
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
    -- Check if session exists
    SELECT EXISTS(SELECT 1 FROM attendance_sessions WHERE id = p_session_id) INTO v_exists;
    IF NOT v_exists THEN
        RAISE EXCEPTION 'Attendance session with ID % does not exist', p_session_id;
    END IF;
    
    -- Check if student exists
    SELECT EXISTS(SELECT 1 FROM students WHERE id = p_student_id) INTO v_exists;
    IF NOT v_exists THEN
        RAISE EXCEPTION 'Student with ID % does not exist', p_student_id;
    END IF;
    
    -- Check if status is valid
    IF p_status NOT IN ('present', 'absent', 'late') THEN
        RAISE EXCEPTION 'Invalid status: %. Must be present, absent, or late', p_status;
    END IF;
    
    -- Check if record already exists
    SELECT id FROM attendance_records 
    WHERE session_id = p_session_id AND student_id = p_student_id 
    INTO v_record_id;
    
    IF v_record_id IS NOT NULL THEN
        -- Update existing record
        UPDATE attendance_records
        SET status = p_status, remarks = p_remarks, updated_at = NOW()
        WHERE id = v_record_id;
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

-- =============================================
-- STEP 6: Create sample data (optional)
-- =============================================

-- Insert sample subjects
INSERT INTO subjects (name, code) VALUES
('Mathematics', 'MATH101'),
('Physics', 'PHYS101'),
('Computer Science', 'CS101'),
('English', 'ENG101'),
('Chemistry', 'CHEM101')
ON CONFLICT DO NOTHING;

-- Insert sample courses
INSERT INTO courses (name, code) VALUES
('Computer Science', 'CS'),
('Electrical Engineering', 'EE'),
('Mechanical Engineering', 'ME'),
('Civil Engineering', 'CE'),
('Business Administration', 'BA')
ON CONFLICT DO NOTHING;

-- =============================================
-- STEP 7: Create views for easier querying
-- =============================================

-- View for classes with subject and course names
CREATE OR REPLACE VIEW view_classes AS
SELECT 
    c.id,
    c.teacher_id,
    c.subject_id,
    c.course_id,
    c.year,
    c.section,
    s.name AS subject_name,
    s.code AS subject_code,
    co.name AS course_name,
    co.code AS course_code,
    c.created_at,
    c.updated_at
FROM 
    classes c
JOIN 
    subjects s ON c.subject_id = s.id
JOIN 
    courses co ON c.course_id = co.id;

-- View for class students with student details
CREATE OR REPLACE VIEW view_class_students AS
SELECT 
    cs.id,
    cs.class_id,
    cs.student_id,
    s.name AS student_name,
    s.roll_number,
    s.email AS student_email,
    c.teacher_id,
    c.subject_id,
    c.course_id,
    c.year,
    c.section,
    sub.name AS subject_name,
    co.name AS course_name,
    cs.created_at,
    cs.updated_at
FROM 
    class_students cs
JOIN 
    students s ON cs.student_id = s.id
JOIN 
    classes c ON cs.class_id = c.id
JOIN 
    subjects sub ON c.subject_id = sub.id
JOIN 
    courses co ON c.course_id = co.id;

-- View for attendance records with session and student details
CREATE OR REPLACE VIEW view_attendance_records AS
SELECT 
    ar.id,
    ar.session_id,
    ar.student_id,
    ar.status,
    ar.remarks,
    s.name AS student_name,
    s.roll_number,
    ats.class_id,
    ats.date AS session_date,
    ats.start_time,
    ats.end_time,
    c.teacher_id,
    c.subject_id,
    c.course_id,
    c.year,
    c.section,
    sub.name AS subject_name,
    co.name AS course_name,
    ar.created_at,
    ar.updated_at
FROM 
    attendance_records ar
JOIN 
    students s ON ar.student_id = s.id
JOIN 
    attendance_sessions ats ON ar.session_id = ats.id
JOIN 
    classes c ON ats.class_id = c.id
JOIN 
    subjects sub ON c.subject_id = sub.id
JOIN 
    courses co ON c.course_id = co.id;

-- =============================================
-- STEP 8: Create functions for statistics
-- =============================================

-- Function to get attendance statistics for a class
CREATE OR REPLACE FUNCTION get_class_attendance_stats(class_id UUID)
RETURNS TABLE (
    total_sessions BIGINT,
    total_students BIGINT,
    present_count BIGINT,
    absent_count BIGINT,
    late_count BIGINT,
    average_attendance NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    WITH session_counts AS (
        SELECT COUNT(*) AS session_count
        FROM attendance_sessions
        WHERE class_id = $1
    ),
    student_counts AS (
        SELECT COUNT(*) AS student_count
        FROM class_students
        WHERE class_id = $1
    ),
    status_counts AS (
        SELECT 
            ar.status,
            COUNT(*) AS count
        FROM 
            attendance_records ar
        JOIN 
            attendance_sessions ats ON ar.session_id = ats.id
        WHERE 
            ats.class_id = $1
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
        stc.student_count AS total_students,
        COALESCE((SELECT count FROM status_counts WHERE status = 'present'), 0) AS present_count,
        COALESCE((SELECT count FROM status_counts WHERE status = 'absent'), 0) AS absent_count,
        COALESCE((SELECT count FROM status_counts WHERE status = 'late'), 0) AS late_count,
        CASE 
            WHEN tp.total > 0 THEN 
                (COALESCE((SELECT count FROM status_counts WHERE status = 'present'), 0) + 
                 COALESCE((SELECT count FROM status_counts WHERE status = 'late'), 0) * 0.5) / tp.total * 100
            ELSE 0
        END AS average_attendance
    FROM 
        session_counts sc, 
        student_counts stc,
        total_possible tp;
END;
$$ LANGUAGE plpgsql;

-- Function to get attendance statistics for a student in a class
CREATE OR REPLACE FUNCTION get_student_attendance_stats(class_id UUID, student_id UUID)
RETURNS TABLE (
    total_sessions BIGINT,
    present_count BIGINT,
    absent_count BIGINT,
    late_count BIGINT,
    attendance_percentage NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    WITH session_counts AS (
        SELECT COUNT(*) AS session_count
        FROM attendance_sessions
        WHERE class_id = $1
    ),
    status_counts AS (
        SELECT 
            ar.status,
            COUNT(*) AS count
        FROM 
            attendance_records ar
        JOIN 
            attendance_sessions ats ON ar.session_id = ats.id
        WHERE 
            ats.class_id = $1 AND ar.student_id = $2
        GROUP BY 
            ar.status
    )
    SELECT 
        sc.session_count AS total_sessions,
        COALESCE((SELECT count FROM status_counts WHERE status = 'present'), 0) AS present_count,
        COALESCE((SELECT count FROM status_counts WHERE status = 'absent'), 0) AS absent_count,
        COALESCE((SELECT count FROM status_counts WHERE status = 'late'), 0) AS late_count,
        CASE 
            WHEN sc.session_count > 0 THEN 
                (COALESCE((SELECT count FROM status_counts WHERE status = 'present'), 0) + 
                 COALESCE((SELECT count FROM status_counts WHERE status = 'late'), 0) * 0.5) / sc.session_count * 100
            ELSE 0
        END AS attendance_percentage
    FROM 
        session_counts sc;
END;
$$ LANGUAGE plpgsql;

-- Function to get attendance statistics for a date range
CREATE OR REPLACE FUNCTION get_attendance_stats_for_date_range(
    class_id UUID, 
    start_date DATE, 
    end_date DATE
)
RETURNS TABLE (
    total_sessions BIGINT,
    present_count BIGINT,
    absent_count BIGINT,
    late_count BIGINT,
    average_attendance NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    WITH session_counts AS (
        SELECT COUNT(*) AS session_count
        FROM attendance_sessions
        WHERE class_id = $1 AND date >= $2 AND date <= $3
    ),
    student_counts AS (
        SELECT COUNT(*) AS student_count
        FROM class_students
        WHERE class_id = $1
    ),
    status_counts AS (
        SELECT 
            ar.status,
            COUNT(*) AS count
        FROM 
            attendance_records ar
        JOIN 
            attendance_sessions ats ON ar.session_id = ats.id
        WHERE 
            ats.class_id = $1 AND ats.date >= $2 AND ats.date <= $3
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
        CASE 
            WHEN tp.total > 0 THEN 
                (COALESCE((SELECT count FROM status_counts WHERE status = 'present'), 0) + 
                 COALESCE((SELECT count FROM status_counts WHERE status = 'late'), 0) * 0.5) / tp.total * 100
            ELSE 0
        END AS average_attendance
    FROM 
        session_counts sc, 
        student_counts stc,
        total_possible tp;
END;
$$ LANGUAGE plpgsql;

-- Function to safely add a student to a class with error handling
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
    -- Check if class exists
    SELECT EXISTS(SELECT 1 FROM classes WHERE id = p_class_id) INTO v_exists;
    IF NOT v_exists THEN
        RAISE EXCEPTION 'Class with ID % does not exist', p_class_id;
    END IF;
    
    -- Check if student with roll number already exists
    SELECT id FROM students WHERE roll_number = p_roll_number INTO v_student_id;
    
    IF v_student_id IS NULL THEN
        -- Create new student
        INSERT INTO students (name, roll_number, created_at)
        VALUES (p_student_name, p_roll_number, NOW())
        RETURNING id INTO v_student_id;
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

-- Function to safely create an attendance session with error handling
CREATE OR REPLACE FUNCTION create_attendance_session(
    p_class_id UUID,
    p_date DATE,
    p_start_time TEXT,
    p_end_time TEXT,
    p_created_by UUID
)
RETURNS UUID AS $$
DECLARE
    v_session_id UUID;
    v_exists BOOLEAN;
BEGIN
    -- Check if class exists
    SELECT EXISTS(SELECT 1 FROM classes WHERE id = p_class_id) INTO v_exists;
    IF NOT v_exists THEN
        RAISE EXCEPTION 'Class with ID % does not exist', p_class_id;
    END IF;
    
    -- Check if session for this date already exists
    SELECT EXISTS(
        SELECT 1 FROM attendance_sessions 
        WHERE class_id = p_class_id AND date = p_date
    ) INTO v_exists;
    
    IF v_exists THEN
        RAISE EXCEPTION 'Attendance session for class % on date % already exists', p_class_id, p_date;
    END IF;
    
    -- Create attendance session
    INSERT INTO attendance_sessions (class_id, date, start_time, end_time, created_by, created_at)
    VALUES (p_class_id, p_date, p_start_time, p_end_time, p_created_by, NOW())
    RETURNING id INTO v_session_id;
    
    RETURN v_session_id;
EXCEPTION
    WHEN unique_violation THEN
        RAISE EXCEPTION 'Attendance session for this class and date already exists';
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error creating attendance session: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- Function to safely submit attendance with error handling
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
    -- Check if session exists
    SELECT EXISTS(SELECT 1 FROM attendance_sessions WHERE id = p_session_id) INTO v_exists;
    IF NOT v_exists THEN
        RAISE EXCEPTION 'Attendance session with ID % does not exist', p_session_id;
    END IF;
    
    -- Check if student exists
    SELECT EXISTS(SELECT 1 FROM students WHERE id = p_student_id) INTO v_exists;
    IF NOT v_exists THEN
        RAISE EXCEPTION 'Student with ID % does not exist', p_student_id;
    END IF;
    
    -- Check if status is valid
    IF p_status NOT IN ('present', 'absent', 'late') THEN
        RAISE EXCEPTION 'Invalid status: %. Must be present, absent, or late', p_status;
    END IF;
    
    -- Check if record already exists
    SELECT id FROM attendance_records 
    WHERE session_id = p_session_id AND student_id = p_student_id 
    INTO v_record_id;
    
    IF v_record_id IS NOT NULL THEN
        -- Update existing record
        UPDATE attendance_records
        SET status = p_status, remarks = p_remarks, updated_at = NOW()
        WHERE id = v_record_id;
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

-- =============================================
-- STEP 9: Create error handling functions
-- =============================================

-- Function to safely add a student to a class with error handling
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
    -- Check if class exists
    SELECT EXISTS(SELECT 1 FROM classes WHERE id = p_class_id) INTO v_exists;
    IF NOT v_exists THEN
        RAISE EXCEPTION 'Class with ID % does not exist', p_class_id;
    END IF;
    
    -- Check if student with roll number already exists
    SELECT id FROM students WHERE roll_number = p_roll_number INTO v_student_id;
    
    IF v_student_id IS NULL THEN
        -- Create new student
        INSERT INTO students (name, roll_number, created_at)
        VALUES (p_student_name, p_roll_number, NOW())
        RETURNING id INTO v_student_id;
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

-- Function to safely create an attendance session with error handling
CREATE OR REPLACE FUNCTION create_attendance_session(
    p_class_id UUID,
    p_date DATE,
    p_start_time TEXT,
    p_end_time TEXT,
    p_created_by UUID
)
RETURNS UUID AS $$
DECLARE
    v_session_id UUID;
    v_exists BOOLEAN;
BEGIN
    -- Check if class exists
    SELECT EXISTS(SELECT 1 FROM classes WHERE id = p_class_id) INTO v_exists;
    IF NOT v_exists THEN
        RAISE EXCEPTION 'Class with ID % does not exist', p_class_id;
    END IF;
    
    -- Check if session for this date already exists
    SELECT EXISTS(
        SELECT 1 FROM attendance_sessions 
        WHERE class_id = p_class_id AND date = p_date
    ) INTO v_exists;
    
    IF v_exists THEN
        RAISE EXCEPTION 'Attendance session for class % on date % already exists', p_class_id, p_date;
    END IF;
    
    -- Create attendance session
    INSERT INTO attendance_sessions (class_id, date, start_time, end_time, created_by, created_at)
    VALUES (p_class_id, p_date, p_start_time, p_end_time, p_created_by, NOW())
    RETURNING id INTO v_session_id;
    
    RETURN v_session_id;
EXCEPTION
    WHEN unique_violation THEN
        RAISE EXCEPTION 'Attendance session for this class and date already exists';
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error creating attendance session: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- Function to safely submit attendance with error handling
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
    -- Check if session exists
    SELECT EXISTS(SELECT 1 FROM attendance_sessions WHERE id = p_session_id) INTO v_exists;
    IF NOT v_exists THEN
        RAISE EXCEPTION 'Attendance session with ID % does not exist', p_session_id;
    END IF;
    
    -- Check if student exists
    SELECT EXISTS(SELECT 1 FROM students WHERE id = p_student_id) INTO v_exists;
    IF NOT v_exists THEN
        RAISE EXCEPTION 'Student with ID % does not exist', p_student_id;
    END IF;
    
    -- Check if status is valid
    IF p_status NOT IN ('present', 'absent', 'late') THEN
        RAISE EXCEPTION 'Invalid status: %. Must be present, absent, or late', p_status;
    END IF;
    
    -- Check if record already exists
    SELECT id FROM attendance_records 
    WHERE session_id = p_session_id AND student_id = p_student_id 
    INTO v_record_id;
    
    IF v_record_id IS NOT NULL THEN
        -- Update existing record
        UPDATE attendance_records
        SET status = p_status, remarks = p_remarks, updated_at = NOW()
        WHERE id = v_record_id;
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

-- =============================================
-- STEP 10: Commit all changes
-- =============================================
COMMIT;
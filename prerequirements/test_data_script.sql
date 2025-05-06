-- =============================================
-- BCA Course Setup Script for SmartCampus
-- =============================================
-- This script adds the BCA course, its semesters, and subjects
-- to the existing SmartCampus database

BEGIN;

-- =============================================
-- STEP 1: Add BCA Course
-- =============================================

INSERT INTO courses (name, code)
VALUES ('Bachelor of Computer Applications', 'BCA')
ON CONFLICT DO NOTHING;

-- =============================================
-- STEP 2: Add BCA Subjects by Semester
-- =============================================

-- Semester 1 Subjects
INSERT INTO subjects (name, code)
VALUES 
    ('Computer Fundamentals', 'BCA101'),
    ('Mathematics for Computing', 'BCA102'),
    ('Digital Logic', 'BCA103'),
    ('Programming in C', 'BCA104'),
    ('Communication Skills', 'BCA105'),
    ('PC Software Lab', 'BCA106')
ON CONFLICT DO NOTHING;

-- Semester 2 Subjects
INSERT INTO subjects (name, code)
VALUES 
    ('Data Structures', 'BCA201'),
    ('Database Management Systems', 'BCA202'),
    ('Operating Systems', 'BCA203'),
    ('Object Oriented Programming', 'BCA204'),
    ('Financial Accounting', 'BCA205'),
    ('Web Technologies', 'BCA206')
ON CONFLICT DO NOTHING;

-- Semester 3 Subjects
INSERT INTO subjects (name, code)
VALUES 
    ('Computer Networks', 'BCA301'),
    ('Software Engineering', 'BCA302'),
    ('Java Programming', 'BCA303'),
    ('Computer Architecture', 'BCA304'),
    ('Numerical Methods', 'BCA305'),
    ('Mobile Application Development', 'BCA306')
ON CONFLICT DO NOTHING;

-- Semester 4 Subjects
INSERT INTO subjects (name, code)
VALUES 
    ('Internet Technologies', 'BCA401'),
    ('Python Programming', 'BCA402'),
    ('Data Mining and Warehousing', 'BCA403'),
    ('E-Commerce', 'BCA404'),
    ('Computer Graphics', 'BCA405'),
    ('Multimedia Systems', 'BCA406')
ON CONFLICT DO NOTHING;

-- Semester 5 Subjects
INSERT INTO subjects (name, code)
VALUES 
    ('Artificial Intelligence', 'BCA501'),
    ('Cloud Computing', 'BCA502'),
    ('Information Security', 'BCA503'),
    ('Advanced Database Systems', 'BCA504'),
    ('Operations Research', 'BCA505'),
    ('Project Management', 'BCA506')
ON CONFLICT DO NOTHING;

-- Semester 6 Subjects
INSERT INTO subjects (name, code)
VALUES 
    ('Big Data Analytics', 'BCA601'),
    ('Internet of Things', 'BCA602'),
    ('Machine Learning', 'BCA603'),
    ('Enterprise Resource Planning', 'BCA604'),
    ('Final Year Project', 'BCA605')
ON CONFLICT DO NOTHING;

-- =============================================
-- STEP 3: Create Sample Classes for BCA
-- =============================================

-- This function creates sample classes for a teacher
-- You can run this for each teacher who teaches BCA courses
CREATE OR REPLACE FUNCTION create_sample_bca_classes(teacher_uuid UUID)
RETURNS VOID AS $$
DECLARE
    bca_course_id UUID;
    subject_id UUID;
    subject_record RECORD;
BEGIN
    -- Get BCA course ID
    SELECT id INTO bca_course_id FROM courses WHERE code = 'BCA';
    
    -- Create classes for each semester (example for semester 1)
    FOR subject_record IN 
        SELECT id, code FROM subjects WHERE code LIKE 'BCA1%'
    LOOP
        INSERT INTO classes (teacher_id, subject_id, course_id, semester, section)
        VALUES (
            teacher_uuid, 
            subject_record.id, 
            bca_course_id, 
            1, 
            'A'
        )
        ON CONFLICT (teacher_id, subject_id, course_id, semester, section) DO NOTHING;
    END LOOP;
    
    -- You can uncomment and modify these blocks to create classes for other semesters
    /*
    -- Semester 2
    FOR subject_record IN 
        SELECT id, code FROM subjects WHERE code LIKE 'BCA2%'
    LOOP
        INSERT INTO classes (teacher_id, subject_id, course_id, semester, section)
        VALUES (
            teacher_uuid, 
            subject_record.id, 
            bca_course_id, 
            2, 
            'A'
        )
        ON CONFLICT (teacher_id, subject_id, course_id, semester, section) DO NOTHING;
    END LOOP;
    
    -- Add more semesters as needed
    */
END;
$$ LANGUAGE plpgsql;

-- =============================================
-- STEP 4: Create Sample Students for BCA
-- =============================================

-- This function creates sample students for BCA course
CREATE OR REPLACE FUNCTION create_sample_bca_students(num_students INTEGER DEFAULT 30)
RETURNS VOID AS $$
DECLARE
    i INTEGER;
    roll_prefix TEXT := 'BCA';
    year_suffix TEXT := substring(EXTRACT(YEAR FROM CURRENT_DATE)::TEXT, 3, 2);
    student_id UUID;
    class_id UUID;
BEGIN
    -- Create students
    FOR i IN 1..num_students LOOP
        -- Create roll number like BCA23001, BCA23002, etc.
        INSERT INTO students (name, roll_number)
        VALUES (
            'BCA Student ' || i,
            roll_prefix || year_suffix || LPAD(i::TEXT, 3, '0')
        )
        ON CONFLICT (roll_number) DO NOTHING
        RETURNING id INTO student_id;
        
        -- Optionally add students to classes
        -- This is just an example for one class, you would need to expand this
        IF student_id IS NOT NULL THEN
            -- Get a class ID (example: first semester class)
            SELECT id INTO class_id 
            FROM classes 
            WHERE course_id = (SELECT id FROM courses WHERE code = 'BCA')
            AND semester = 1
            LIMIT 1;
            
            IF class_id IS NOT NULL THEN
                INSERT INTO class_students (class_id, student_id)
                VALUES (class_id, student_id)
                ON CONFLICT (class_id, student_id) DO NOTHING;
            END IF;
        END IF;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- =============================================
-- STEP 5: Usage Examples (commented out)
-- =============================================

/*
-- Example: To create classes for a specific teacher
-- Replace 'teacher-uuid-here' with an actual teacher UUID
SELECT create_sample_bca_classes('teacher-uuid-here');

-- Example: To create 30 sample BCA students
SELECT create_sample_bca_students(30);
*/

-- =============================================
-- STEP 6: Commit all changes
-- =============================================
COMMIT;

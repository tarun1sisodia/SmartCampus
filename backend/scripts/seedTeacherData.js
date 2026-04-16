import dotenv from 'dotenv';
dotenv.config();

import mongoose from 'mongoose';
import User from '../src/models/User.model.js';
import Organisation from '../src/models/Organisation.model.js';
import Course from '../src/models/Course.model.js';
import Subject from '../src/models/Subject.model.js';
import Semester from '../src/models/Semester.model.js';
import Section from '../src/models/Section.model.js';
import Student from '../src/models/Student.model.js';
import Session from '../src/models/Session.model.js';

async function seedTeacherData() {
  await mongoose.connect(process.env.MONGO_URI || 'mongodb://localhost:27017/smartcampus');
  console.log('📡 Connected to MongoDB');

  // 1. Get or Create Organisation
  let org = await Organisation.findOne({ name: 'Demo School' });
  if (!org) {
    org = await Organisation.create({
      name: 'Demo School',
      type: 'school',
      status: 'active',
      subscription: { plan: 'premium', maxTeachers: 50, maxStudents: 1000 },
    });
  }

  // 2. Create Teacher
  const teacherEmail = 'teacher@demo.com';
  let teacher = await User.findOne({ email: teacherEmail });
  if (!teacher) {
    teacher = await User.create({
      name: 'John Teacher',
      email: teacherEmail,
      password: 'TeacherPass123',
      role: 'teacher',
      organisation: org._id,
      isActive: true,
    });
    console.log(`✅ Teacher created: ${teacherEmail} / TeacherPass123`);
  }

  // 3. Create Course
  let course = await Course.findOne({ code: 'CS101', organisation: org._id });
  if (!course) {
    course = await Course.create({
      name: 'Computer Science',
      code: 'CS101',
      organisation: org._id,
      durationYears: 4,
    });
    console.log('✅ Course created: Computer Science');
  }

  // 4. Create Semester
  let semester = await Semester.findOne({ name: 'Spring 2024', organisation: org._id });
  if (!semester) {
    semester = await Semester.create({
      name: 'Spring 2024',
      startDate: new Date('2024-01-01'),
      endDate: new Date('2024-06-30'),
      isActive: true,
      organisation: org._id,
    });
    console.log('✅ Semester created: Spring 2024');
  }

  // 5. Create Subject
  let subject = await Subject.findOne({ code: 'DS101', course: course._id });
  if (!subject) {
    subject = await Subject.create({
      name: 'Data Structures',
      code: 'DS101',
      course: course._id,
      semester: 1,
      organisation: org._id,
    });
    console.log('✅ Subject created: Data Structures');
  }

  // 6. Create Section
  let section = await Section.findOne({ name: 'Section A', course: course._id, semester: semester._id });
  if (!section) {
    section = await Section.create({
      name: 'Section A',
      course: course._id,
      semester: semester._id,
      classTeacher: teacher._id,
      organisation: org._id,
    });
    console.log('✅ Section created: Section A');
  }

  // 7. Create Students
  const studentsData = [
    { rollNumber: 'S001', name: 'Alice Smith' },
    { rollNumber: 'S002', name: 'Bob Johnson' },
    { rollNumber: 'S003', name: 'Charlie Brown' },
  ];

  for (const sData of studentsData) {
    const existing = await Student.findOne({ rollNumber: sData.rollNumber, organisation: org._id });
    if (!existing) {
      await Student.create({
        ...sData,
        course: course._id,
        semester: semester._id,
        section: section._id,
        organisation: org._id,
        enrollmentYear: 2024,
      });
      console.log(`✅ Student created: ${sData.name}`);
    }
  }

  // 8. Create Sessions (for today)
  const today = new Date();
  today.setHours(0, 0, 0, 0);

  const existingSession = await Session.findOne({ 
    teacher: teacher._id, 
    date: today,
    subject: subject._id
  });

  if (!existingSession) {
    await Session.create({
      subject: subject._id,
      course: course._id,
      semester: semester._id,
      section: section._id,
      teacher: teacher._id,
      date: today,
      startTime: '09:00',
      endTime: '10:00',
      topic: 'Introduction to Linked Lists',
      organisation: org._id,
    });
    console.log('✅ Session created for today at 09:00 AM');
  }

  console.log('\n🚀 Teacher data seeding complete!');
  await mongoose.disconnect();
}

seedTeacherData().catch(err => {
  console.error('❌ Seeding failed:', err);
  process.exit(1);
});

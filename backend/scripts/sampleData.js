import dotenv from 'dotenv';
dotenv.config();

import mongoose from 'mongoose';
import Organisation from '../src/models/Organisation.model.js';
import User from '../src/models/User.model.js';
import Course from '../src/models/Course.model.js';
import Subject from '../src/models/Subject.model.js';
import Semester from '../src/models/Semester.model.js';
import Section from '../src/models/Section.model.js';
import Student from '../src/models/Student.model.js';

async function addSampleData() {
  await mongoose.connect(process.env.MONGO_URI || 'mongodb://localhost:27017/smartcampus');

  const org = await Organisation.findOne({ name: 'Demo School' });
  if (!org) throw new Error('No organisation found. Run seed.js first.');

  // Create a course
  let course = await Course.findOne({ code: 'CS101', organisation: org._id });
  if (!course) {
    course = await Course.create({
      name: 'Computer Science',
      code: 'CS101',
      organisation: org._id,
      durationYears: 4,
    });
  }

  // Create a semester
  let semester = await Semester.findOne({ name: 'Fall 2025', organisation: org._id });
  if (!semester) {
    semester = await Semester.create({
      name: 'Fall 2025',
      startDate: new Date('2025-09-01'),
      endDate: new Date('2025-12-20'),
      isActive: true,
      organisation: org._id,
    });
  }

  // Create a subject
  let subject = await Subject.findOne({ code: 'CS201', organisation: org._id });
  if (!subject) {
    subject = await Subject.create({
      name: 'Data Structures',
      code: 'CS201',
      credits: 4,
      course: course._id,
      semester: semester._id,
      organisation: org._id,
    });
  }

  // Create a section
  let section = await Section.findOne({ name: 'A', organisation: org._id });
  if (!section) {
    section = await Section.create({
      name: 'A',
      course: course._id,
      semester: semester._id,
      organisation: org._id,
    });
  }

  // Create a teacher (invited, then accept)
  let teacher = await User.findOne({ email: 'teacher@demo.com' });
  if (!teacher) {
    teacher = await User.create({
      name: 'John Teacher',
      email: 'teacher@demo.com',
      password: 'Teacher123!',
      role: 'teacher',
      organisation: org._id,
      isActive: true,
    });
  }

  // Create 10 sample students
  for (let i = 1; i <= 10; i++) {
    const sEmail = `student${i}@demo.com`;
    const sRoll = `CS${String(i).padStart(3,'0')}`;
    const existSt = await Student.findOne({ rollNumber: sRoll, organisation: org._id });
    if (!existSt) {
      await Student.create({
        rollNumber: sRoll,
        name: `Student ${i}`,
        email: sEmail,
        course: course._id,
        semester: semester._id,
        section: section._id,
        organisation: org._id,
        enrollmentYear: 2025,
      });
    }
  }

  console.log('✅ Sample data added: course, subject, semester, section, teacher, 10 students');
  await mongoose.disconnect();
  process.exit(0);
}

addSampleData().catch(err => { 
  console.error(err); 
  process.exit(1); 
});

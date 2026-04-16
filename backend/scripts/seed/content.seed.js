import { faker } from '@faker-js/faker';
import User from '../../src/models/User.model.js';
import Student from '../../src/models/Student.model.js';
import Course from '../../src/models/Course.model.js';
import Subject from '../../src/models/Subject.model.js';
import Semester from '../../src/models/Semester.model.js';
import Section from '../../src/models/Section.model.js';
import Session from '../../src/models/Session.model.js';

export async function seedOrgContent(org, teachersCount = 50, studentsPerTeacher = 20) {
  console.log(`🚀 Seeding content for ${org.name} (${teachersCount} teachers)...`);

  // 1. Create a Course
  const course = await Course.create({
    name: faker.commerce.department() + ' Sciences',
    code: faker.string.alphanumeric(5).toUpperCase(),
    durationYears: 4,
    organisation: org._id
  });

  // 2. Create Semester and Section
  const semester = await Semester.create({
    name: 'Fall 2024',
    startDate: new Date('2024-01-01'),
    endDate: new Date('2024-12-31'),
    course: course._id,
    organisation: org._id
  });

  const section = await Section.create({
    name: 'Section Alpha',
    course: course._id,
    semester: semester._id,
    organisation: org._id
  });

  // 3. Create Subjects
  const subjects = [];
  for (let i = 0; i < 5; i++) {
    const sub = await Subject.create({
      name: faker.commerce.productName(),
      code: faker.string.alphanumeric(4).toUpperCase(),
      course: course._id,
      semester: 1,
      organisation: org._id
    });
    subjects.push(sub);
  }

  // 4. Create Teachers and Students
  for (let t = 0; t < teachersCount; t++) {
    let teacher;
    try {
      teacher = await User.create({
        name: faker.person.fullName(),
        email: `teacher${t}@${org.name.toLowerCase().replace(/ /g, '')}.com`, // deterministic
        password: 'TeacherPassword123',
        role: 'teacher',
        organisation: org._id,
        isActive: true
      });
    } catch (e) {
      if (e.code === 11000) {
        teacher = await User.findOne({ email: `teacher${t}@${org.name.toLowerCase().replace(/ /g, '')}.com` });
      } else {
        throw e;
      }
    }
    
    if (!teacher) continue; // safety check

    // Create students for this teacher's context
    // Create students for this teacher's context
    for (let s = 0; s < studentsPerTeacher; s++) {
      try {
        await Student.create({
          name: faker.person.fullName(),
          rollNumber: `ROLL-${t}-${s}-${faker.string.numeric(4)}`, // More unique
          email: faker.internet.email().toLowerCase(),
          course: course._id,
          semester: semester._id,
          section: section._id,
          organisation: org._id
        });
      } catch (e) {
        if (e.code === 11000) continue; // Skip duplicates
        throw e;
      }
    }

    // Create Sessions for today for this teacher
    for (const sub of subjects) {
      await Session.create({
        subject: sub._id,
        course: course._id,
        semester: semester._id,
        section: section._id,
        teacher: teacher._id,
        date: new Date().setHours(0,0,0,0),
        startTime: `0${9 + (t % 5)}:00`,
        endTime: `1${0 + (t % 5)}:00`,
        topic: faker.company.catchPhrase(),
        organisation: org._id
      });
    }

    if (t % 10 === 0) console.log(`  ...seeded ${t} teachers`);
  }

  console.log(`✅ Finished seeding ${org.name}`);
}

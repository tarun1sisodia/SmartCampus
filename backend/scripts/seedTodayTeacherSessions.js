import fs from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import dotenv from 'dotenv';
import mongoose from 'mongoose';

import Organisation from '../src/models/Organisation.model.js';
import User from '../src/models/User.model.js';
import Course from '../src/models/Course.model.js';
import Semester from '../src/models/Semester.model.js';
import Section from '../src/models/Section.model.js';
import Subject from '../src/models/Subject.model.js';
import Student from '../src/models/Student.model.js';
import Session from '../src/models/Session.model.js';

dotenv.config();

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const defaultSeedPath = path.join(__dirname, 'data', 'today-teacher-sessions.seed.json');
const seedPath = process.env.SEED_FILE || defaultSeedPath;
const mongoUri = process.env.MONGO_URI || 'mongodb://localhost:27017/smartcampus';

const atMidnight = (date) => {
  const d = new Date(date);
  d.setHours(0, 0, 0, 0);
  return d;
};

const addDays = (date, days) => {
  const d = new Date(date);
  d.setDate(d.getDate() + days);
  return d;
};

async function readSeedConfig() {
  const raw = await fs.readFile(seedPath, 'utf-8');
  return JSON.parse(raw);
}

async function upsertOrganisation(cfg) {
  let org = await Organisation.findOne({ name: cfg.name });
  if (!org) {
    org = await Organisation.create(cfg);
    console.log(`✅ Created organisation: ${org.name}`);
  } else {
    await Organisation.updateOne({ _id: org._id }, { $set: cfg });
    org = await Organisation.findById(org._id);
    console.log(`ℹ️ Reused organisation: ${org?.name}`);
  }
  return org;
}

async function upsertCourse(org, cfg) {
  let course = await Course.findOne({ code: cfg.code, organisation: org._id });
  if (!course) {
    course = await Course.create({ ...cfg, organisation: org._id });
    console.log(`✅ Created course: ${course.name}`);
  } else {
    console.log(`ℹ️ Reused course: ${course.name}`);
  }
  return course;
}

async function upsertSemester(org, cfg) {
  const now = new Date();
  const startDate = addDays(now, cfg.startDateOffsetDays ?? -30);
  const endDate = addDays(now, cfg.endDateOffsetDays ?? 120);
  const semesterQuery = { name: cfg.name, organisation: org._id };
  const semesterData = {
    ...semesterQuery,
    startDate,
    endDate,
    isActive: cfg.isActive ?? true,
  };

  let semester = await Semester.findOne(semesterQuery);
  if (!semester) {
    semester = await Semester.create(semesterData);
    console.log(`✅ Created semester: ${semester.name}`);
  } else {
    await Semester.updateOne({ _id: semester._id }, { $set: semesterData });
    semester = await Semester.findById(semester._id);
    console.log(`ℹ️ Reused semester: ${semester?.name}`);
  }
  return semester;
}

async function upsertSubjects(org, course, subjectConfigs) {
  const subjects = [];
  for (const cfg of subjectConfigs) {
    let subject = await Subject.findOne({
      code: cfg.code,
      course: course._id,
      organisation: org._id,
    });
    if (!subject) {
      subject = await Subject.create({
        name: cfg.name,
        code: cfg.code,
        semester: cfg.semesterNumber ?? 1,
        course: course._id,
        organisation: org._id,
      });
      console.log(`✅ Created subject: ${subject.name}`);
    } else {
      console.log(`ℹ️ Reused subject: ${subject.name}`);
    }
    subjects.push(subject);
  }
  return subjects;
}

async function upsertTeachers(org, teacherConfigs) {
  const teachers = [];
  for (const cfg of teacherConfigs) {
    let teacher = await User.findOne({ email: cfg.email });
    if (!teacher) {
      teacher = await User.create({
        name: cfg.name,
        email: cfg.email,
        password: cfg.password,
        role: 'teacher',
        organisation: org._id,
        isActive: true,
      });
      console.log(`✅ Created teacher: ${cfg.email}`);
    } else {
      if (!teacher.organisation || String(teacher.organisation) !== String(org._id)) {
        teacher.organisation = org._id;
      }
      teacher.role = 'teacher';
      teacher.isActive = true;
      teacher.name = cfg.name;
      await teacher.save();
      console.log(`ℹ️ Reused teacher: ${cfg.email}`);
    }
    teachers.push(teacher);
  }
  return teachers;
}

async function upsertSection(org, course, semester, classTeacher, cfg) {
  let section = await Section.findOne({
    name: cfg.name,
    course: course._id,
    semester: semester._id,
  });
  if (!section) {
    section = await Section.create({
      name: cfg.name,
      course: course._id,
      semester: semester._id,
      classTeacher: classTeacher?._id,
      organisation: org._id,
    });
    console.log(`✅ Created section: ${section.name}`);
  } else {
    if (classTeacher?._id) {
      section.classTeacher = classTeacher._id;
      await section.save();
    }
    console.log(`ℹ️ Reused section: ${section.name}`);
  }
  return section;
}

async function upsertStudents(org, course, semester, section, studentConfigs) {
  for (const cfg of studentConfigs) {
    const existing = await Student.findOne({
      rollNumber: cfg.rollNumber,
      organisation: org._id,
    });
    if (!existing) {
      await Student.create({
        rollNumber: cfg.rollNumber,
        name: cfg.name,
        enrollmentYear: cfg.enrollmentYear,
        organisation: org._id,
        course: course._id,
        semester: semester._id,
        section: section._id,
      });
      console.log(`✅ Created student: ${cfg.rollNumber}`);
    }
  }
}

async function createUpcomingSessions(
  org,
  teachers,
  subjects,
  course,
  semester,
  section,
  slots,
  daysCount,
) {
  const baseDate = atMidnight(new Date());
  let createdCount = 0;

  for (let dayOffset = 0; dayOffset < daysCount; dayOffset += 1) {
    const sessionDate = addDays(baseDate, dayOffset);
    for (const teacher of teachers) {
      for (let i = 0; i < slots.length; i += 1) {
        const slot = slots[i];
        const subject = subjects[i % subjects.length];
        const topicPrefix = slot.topicPrefix || 'Session';
        const topic = `${topicPrefix} - ${subject.name}`;

        const existing = await Session.findOne({
          organisation: org._id,
          teacher: teacher._id,
          subject: subject._id,
          date: sessionDate,
          startTime: slot.startTime,
          endTime: slot.endTime,
        });

        if (!existing) {
          await Session.create({
            subject: subject._id,
            course: course._id,
            semester: semester._id,
            section: section._id,
            teacher: teacher._id,
            date: sessionDate,
            startTime: slot.startTime,
            endTime: slot.endTime,
            topic,
            organisation: org._id,
          });
          createdCount += 1;
        }
      }
    }
  }

  console.log(`✅ Upcoming sessions seeded for ${daysCount} day(s) (new): ${createdCount}`);
}

async function seedTodayTeacherSessions() {
  const config = await readSeedConfig();
  await mongoose.connect(mongoUri);
  console.log('📡 Connected to MongoDB');

  try {
    const organisation = await upsertOrganisation(config.organisation);
    const course = await upsertCourse(organisation, config.course);
    const semester = await upsertSemester(organisation, config.semester);
    const subjects = await upsertSubjects(organisation, course, config.subjects);
    const teachers = await upsertTeachers(organisation, config.teachers);
    const section = await upsertSection(
      organisation,
      course,
      semester,
      teachers[0],
      config.section,
    );
    await upsertStudents(
      organisation,
      course,
      semester,
      section,
      config.students,
    );
    await createUpcomingSessions(
      organisation,
      teachers,
      subjects,
      course,
      semester,
      section,
      config.sessionSlots,
      Math.max(Number(config.sessionDays || 1), 1),
    );

    console.log('\n🚀 Teacher session seeding complete.');
    console.log(`Seed file: ${seedPath}`);
  } finally {
    await mongoose.disconnect();
  }
}

seedTodayTeacherSessions().catch((error) => {
  console.error('❌ Seeding failed:', error);
  process.exit(1);
});

import { Database } from '@nozbe/watermelondb';
import SQLiteAdapter from '@nozbe/watermelondb/adapters/sqlite';
import schema from './schema';
import { User, Class, Student, AttendanceSession, AttendanceRecord } from './models';

const adapter = new SQLiteAdapter({
  schema,
  // standard config for Expo or RN
  jsi: false, /* using default bridge for maximum stability in bare expo */
  onSetUpError: error => {
    console.error('WatermelonDB setup error:', error);
  }
});

export const database = new Database({
  adapter,
  modelClasses: [
    User,
    Class,
    Student,
    AttendanceSession,
    AttendanceRecord,
  ],
});

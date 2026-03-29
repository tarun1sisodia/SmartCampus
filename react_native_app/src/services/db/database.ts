import { Database } from '@nozbe/watermelondb';
import SQLiteAdapter from '@nozbe/watermelondb/adapters/sqlite';
import schema from './schema';
import { User, Class, Student, AttendanceSession, AttendanceRecord } from './models';

import { Platform } from 'react-native';

const adapter = Platform.OS === 'web'
  ? null
  : new SQLiteAdapter({
    schema,
    jsi: false, /* Set to true if JSI is supported by React Native */
    onSetUpError: error => {
      console.log('Database setup error', error);
    }
  });

export const database = new Database({
  adapter: adapter as any,
  modelClasses: [
    User,
    Class,
    Student,
    AttendanceSession,
    AttendanceRecord,
  ],
});

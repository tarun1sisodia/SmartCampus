import { createSlice, createAsyncThunk, PayloadAction } from '@reduxjs/toolkit';
import { StudentModel, AttendanceSessionModel, ClassModel } from '../../models/types';
import { supabase } from '../../services/supabaseClient';

interface AttendanceState {
  students: StudentModel[];
  sessions: AttendanceSessionModel[];
  selectedClass: ClassModel | null;
  isLoading: boolean;
  error: string | null;
}

const initialState: AttendanceState = {
  students: [],
  sessions: [],
  selectedClass: null,
  isLoading: false,
  error: null,
};

import { database } from '../../services/db/database';
import { Student } from '../../services/db/models';
import { Q } from '@nozbe/watermelondb';

export const fetchStudentsForClass = createAsyncThunk(
  'attendance/fetchStudents',
  async (classId: string, { rejectWithValue }) => {
    try {
      // 1. Fetch from Supabase (Online Sync)
      const { data, error } = await supabase
        .from('students')
        .select('*')
        .eq('class_id', classId);

      // 2. Offline Sync: Upsert to WatermelonDB if online was successful
      if (!error && data) {
        await database.write(async () => {
          const studentCollection = database.get<Student>('students');
          
          for (const s of data) {
            // Find if exists
            const existing = await studentCollection.query(Q.where('id', s.id)).fetch();
            if (existing.length > 0) {
              await existing[0].update((record) => {
                record.name = s.name;
                record.rollNumber = s.roll_number;
                record.imageUrl = s.image_url;
              });
            } else {
              await studentCollection.create((record) => {
                // @ts-ignore - id is managed by Watermelon but we override for sync map
                record._raw.id = s.id; 
                record.name = s.name;
                record.rollNumber = s.roll_number;
                record.classId = s.class_id;
                record.imageUrl = s.image_url;
              });
            }
          }
        });
      }

      // 3. Always return from local database as Source of Truth
      const localStudents = await database.get<Student>('students')
        .query(Q.where('class_id', classId))
        .fetch();

      return localStudents.map((s: any) => ({
        id: s.id,
        name: s.name,
        rollNumber: s.rollNumber,
        classId: s.classId,
        imageUrl: s.imageUrl,
        attendanceStatus: 'absent', // Default
      })) as StudentModel[];
    } catch (err: any) {
      // Offline mode fallback: just fetch local
      try {
        const localStudents = await database.get<Student>('students')
          .query(Q.where('class_id', classId))
          .fetch();
        
        return localStudents.map((s: any) => ({
          id: s.id,
          name: s.name,
          rollNumber: s.rollNumber,
          classId: s.classId,
          imageUrl: s.imageUrl,
          attendanceStatus: 'absent',
        })) as StudentModel[];
      } catch (offlineErr) {
        return rejectWithValue(err.message);
      }
    }
  }
);

export const fetchSessions = createAsyncThunk(
  // ... existing code unchanged for fetchSessions (will be overwritten if we don't include it verbatim) ...
// Wait, I should not use ... replace it properly.
  'attendance/fetchSessions',
  async (classId: string, { rejectWithValue }) => {
    try {
      const { data, error } = await supabase
        .from('attendance_sessions')
        .select('*')
        .eq('class_id', classId);

      if (error) throw error;

      return data as AttendanceSessionModel[];
    } catch (err: any) {
      return rejectWithValue(err.message);
    }
  }
);

export const submitAttendance = createAsyncThunk(
  'attendance/submit',
  async ({ sessionId, records }: any, { rejectWithValue }) => {
    try {
      // Offline-First approach: Write to WatermelonDB
      await database.write(async () => {
        const recordCollection = database.get('attendance_records');
        for (const r of records) {
          await recordCollection.create((record: any) => {
            record.sessionId = sessionId;
            record.studentId = r.studentId;
            record.status = r.status;
            record.remarks = r.remarks || '';
          });
        }
      });

      // Try Sync to Supabase
      const { data, error } = await supabase
        .from('attendance_records')
        .upsert(records.map((r: any) => ({
          session_id: sessionId,
          student_id: r.studentId,
          status: r.status,
          remarks: r.remarks,
          created_at: new Date().toISOString(),
        })));

      if (!error) {
        await supabase
          .from('attendance_sessions')
          .update({ status: 'closed' })
          .eq('id', sessionId);
      } else {
        console.warn('Network error: Records saved offline, will sync later.');
      }

      return records;
    } catch (err: any) {
      return rejectWithValue(err.message);
    }
  }
);

const attendanceSlice = createSlice({
  name: 'attendance',
  initialState,
  reducers: {
    setSelectedClass: (state, action: PayloadAction<ClassModel>) => {
      state.selectedClass = action.payload;
    },
    updateStudentStatus: (state, action: PayloadAction<{ studentId: string; status: 'present' | 'absent' | 'late' }>) => {
      const index = state.students.findIndex((s) => s.id === action.payload.studentId);
      if (index !== -1) {
        state.students[index].attendanceStatus = action.payload.status;
      }
    },
  },
  extraReducers: (builder) => {
    builder
      .addCase(fetchStudentsForClass.pending, (state) => {
        state.isLoading = true;
      })
      .addCase(fetchStudentsForClass.fulfilled, (state, action) => {
        state.isLoading = false;
        state.students = action.payload;
      })
      .addCase(fetchStudentsForClass.rejected, (state, action) => {
        state.isLoading = false;
        state.error = action.payload as string;
      });
  },
});

export const { setSelectedClass, updateStudentStatus } = attendanceSlice.actions;
export default attendanceSlice.reducer;

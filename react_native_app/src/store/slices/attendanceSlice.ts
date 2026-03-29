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

export const fetchStudentsForClass = createAsyncThunk(
  'attendance/fetchStudents',
  async (classId: string, { rejectWithValue }) => {
    try {
      const { data, error } = await supabase
        .from('students')
        .select('*')
        .eq('class_id', classId);

      if (error) throw error;

      return data.map((s: any) => ({
        ...s,
        attendanceStatus: 'absent', // Default status as per original Flutter logic
      })) as StudentModel[];
    } catch (err: any) {
      return rejectWithValue(err.message);
    }
  }
);

export const fetchSessions = createAsyncThunk(
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
      const { data, error } = await supabase
        .from('attendance_records')
        .upsert(records.map((r: any) => ({
          session_id: sessionId,
          student_id: r.studentId,
          status: r.status,
          remarks: r.remarks,
          created_at: new Date().toISOString(),
        })));

      if (error) throw error;
      
      // Close the session as per original Flutter logic
      await supabase
        .from('attendance_sessions')
        .update({ status: 'closed' })
        .eq('id', sessionId);

      return data;
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

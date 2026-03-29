import { createSlice, createAsyncThunk, PayloadAction } from '@reduxjs/toolkit';
import { supabase } from '../../services/supabaseClient';
import { UserModel } from '../../models/types';
import * as LocalAuthentication from 'expo-local-authentication';

interface AuthState {
  user: UserModel | null;
  session: any | null;
  isLoading: boolean;
  error: string | null;
  isBiometricEnabled: boolean;
  rememberMe: boolean;
}

const initialState: AuthState = {
  user: null,
  session: null,
  isLoading: false,
  error: null,
  isBiometricEnabled: false,
  rememberMe: false,
};

export const signIn = createAsyncThunk(
  'auth/signIn',
  async ({ email, password }: any, { rejectWithValue }) => {
    try {
      const { data, error } = await supabase.auth.signInWithPassword({
        email,
        password,
      });

      if (error) throw error;

      // Fetch user profile from 'users' table
      const { data: userData, error: userError } = await supabase
        .from('users')
        .select('*')
        .eq('id', data.user.id)
        .single();

      if (userError) throw userError;

      return { session: data.session, user: userData as UserModel };
    } catch (err: any) {
      return rejectWithValue(err.message);
    }
  }
);

export const signUp = createAsyncThunk(
  'auth/signUp',
  async ({ email, password, fullName, phone }: any, { rejectWithValue }) => {
    try {
      const { data, error } = await supabase.auth.signUp({
        email,
        password,
        options: {
          data: { full_name: fullName, phone },
        },
      });

      if (error) throw error;

      // Create user profile in 'users' table
      const { error: insertError } = await supabase.from('users').insert({
        id: data.user?.id,
        fullName,
        email,
        phone,
        role: 'teacher', // Default for now
        created_at: new Date().toISOString(),
      });

      if (insertError) throw insertError;

      return data.user;
    } catch (err: any) {
      return rejectWithValue(err.message);
    }
  }
);

const authSlice = createSlice({
  name: 'auth',
  initialState,
  reducers: {
    setRememberMe: (state, action: PayloadAction<boolean>) => {
      state.rememberMe = action.payload;
    },
    logout: (state) => {
      state.user = null;
      state.session = null;
      supabase.auth.signOut();
    },
  },
  extraReducers: (builder) => {
    builder
      .addCase(signIn.pending, (state) => {
        state.isLoading = true;
        state.error = null;
      })
      .addCase(signIn.fulfilled, (state, action) => {
        state.isLoading = false;
        state.session = action.payload.session;
        state.user = action.payload.user;
      })
      .addCase(signIn.rejected, (state, action) => {
        state.isLoading = false;
        state.error = action.payload as string;
      });
  },
});

export const { setRememberMe, logout } = authSlice.actions;
export default authSlice.reducer;

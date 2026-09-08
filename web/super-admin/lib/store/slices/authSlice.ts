"use client";

import { createAsyncThunk, createSlice, PayloadAction } from "@reduxjs/toolkit";
import { loginApi, logoutApi } from "@/lib/api/endpoints/auth-api";
import { LoginRequest } from "@/types/auth";

type User = { id: string; name: string; email: string; role: string } | null;

type AuthState = {
  user: User;
  accessToken: string | null;
  refreshToken: string | null;
  isAuthenticated: boolean;
};

const initialState: AuthState = {
  user: null,
  accessToken: null,
  refreshToken: null,
  isAuthenticated: false
};

export const login = createAsyncThunk(
  "auth/login",
  async (payload: LoginRequest) => {
    return await loginApi(payload);
  }
);

export const logout = createAsyncThunk("auth/logout", async (_, { getState }) => {
  try {
    const { refreshToken } = (getState() as { auth: AuthState }).auth;
    await logoutApi(refreshToken);
  } catch {
    // Keep logout resilient even when backend call fails.
  }
  return true;
});

const authSlice = createSlice({
  name: "auth",
  initialState,
  reducers: {
    setCredentials: (
      state,
      action: PayloadAction<{ user: User; accessToken: string; refreshToken: string }>
    ) => {
      state.user = action.payload.user;
      state.accessToken = action.payload.accessToken;
      state.refreshToken = action.payload.refreshToken;
      state.isAuthenticated = true;
    },
    clearCredentials: state => {
      state.user = null;
      state.accessToken = null;
      state.refreshToken = null;
      state.isAuthenticated = false;
    }
  },
  extraReducers: builder => {
    builder.addCase(login.fulfilled, (state, action) => {
      state.user = action.payload.user;
      state.accessToken = action.payload.accessToken;
      state.refreshToken = action.payload.refreshToken;
      state.isAuthenticated = true;
    });
    builder.addCase(logout.fulfilled, state => {
      state.user = null;
      state.accessToken = null;
      state.refreshToken = null;
      state.isAuthenticated = false;
    });
  }
});

export const { setCredentials, clearCredentials } = authSlice.actions;
export default authSlice.reducer;

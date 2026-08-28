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

const AUTH_STORAGE_KEY = "smartcampus.auth";

type PersistedAuth = {
  user: User;
  accessToken: string | null;
  refreshToken: string | null;
};

const persistAuth = (state: AuthState) => {
  if (typeof window === "undefined") return;
  try {
    // Session-scoped persistence: survives reloads within the tab but is
    // wiped when the browser session ends. Tokens stay out of cookies.
    const payload: PersistedAuth = {
      user: state.user,
      accessToken: state.accessToken,
      refreshToken: state.refreshToken
    };
    sessionStorage.setItem(AUTH_STORAGE_KEY, JSON.stringify(payload));
  } catch {
    // storage unavailable (private mode) — auth simply won't survive reload
  }
};

const clearPersistedAuth = () => {
  if (typeof window === "undefined") return;
  try {
    sessionStorage.removeItem(AUTH_STORAGE_KEY);
  } catch {
    /* noop */
  }
};

const initialState: AuthState = {
  user: null,
  accessToken: null,
  refreshToken: null,
  isAuthenticated: false
};

/** Restore auth persisted by a previous page load in this tab. */
export const hydrateAuth = (): AuthState => {
  if (typeof window === "undefined") return initialState;
  try {
    const raw = sessionStorage.getItem(AUTH_STORAGE_KEY);
    if (!raw) return initialState;
    const parsed = JSON.parse(raw) as PersistedAuth;
    if (!parsed?.accessToken) return initialState;
    return {
      user: parsed.user ?? null,
      accessToken: parsed.accessToken,
      refreshToken: parsed.refreshToken ?? null,
      isAuthenticated: true
    };
  } catch {
    return initialState;
  }
};

export const login = createAsyncThunk(
  "auth/login",
  async (payload: LoginRequest) => {
    return await loginApi(payload);
  }
);

export const logout = createAsyncThunk("auth/logout", async () => {
  try {
    await logoutApi();
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
      persistAuth(state);
    },
    setAccessToken: (state, action: PayloadAction<{ accessToken: string; refreshToken?: string }>) => {
      state.accessToken = action.payload.accessToken;
      if (action.payload.refreshToken) state.refreshToken = action.payload.refreshToken;
      persistAuth(state);
    },
    clearCredentials: state => {
      state.user = null;
      state.accessToken = null;
      state.refreshToken = null;
      state.isAuthenticated = false;
      clearPersistedAuth();
    }
  },
  extraReducers: builder => {
    builder.addCase(login.fulfilled, (state, action) => {
      state.user = action.payload.user ?? null;
      state.accessToken = action.payload.accessToken;
      state.refreshToken = action.payload.refreshToken ?? null;
      state.isAuthenticated = true;
      persistAuth(state);
    });
    builder.addCase(login.rejected, state => {
      state.user = null;
      state.accessToken = null;
      state.refreshToken = null;
      state.isAuthenticated = false;
      clearPersistedAuth();
    });
    builder.addCase(logout.fulfilled, state => {
      state.user = null;
      state.accessToken = null;
      state.refreshToken = null;
      state.isAuthenticated = false;
      clearPersistedAuth();
    });
  }
});

export const { setCredentials, clearCredentials, setAccessToken } = authSlice.actions;
export { AUTH_STORAGE_KEY };
export default authSlice.reducer;

"use client";

import { configureStore } from "@reduxjs/toolkit";
import authReducer, { hydrateAuth } from "@/lib/store/slices/authSlice";
import { injectStore } from "@/lib/api/axios-client";

export const store = configureStore({
  preloadedState: {
    auth: hydrateAuth()
  },
  reducer: {
    auth: authReducer
  }
});

injectStore(store);

export type RootState = ReturnType<typeof store.getState>;
export type AppDispatch = typeof store.dispatch;

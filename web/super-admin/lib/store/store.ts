"use client";

import { configureStore } from "@reduxjs/toolkit";
import authReducer from "@/lib/store/slices/authSlice";
import { injectStore } from "@/lib/api/axios-client";

export const store = configureStore({
  reducer: {
    auth: authReducer
  }
});

injectStore(store);

export type RootState = ReturnType<typeof store.getState>;
export type AppDispatch = typeof store.dispatch;

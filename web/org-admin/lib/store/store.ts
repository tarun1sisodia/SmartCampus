import { configureStore } from "@reduxjs/toolkit";
import authReducer, { hydrateAuth } from "./slices/authSlice";
import { injectStore } from "../api/axios-client";

export const store = configureStore({
  reducer: {
    auth: authReducer
  },
  preloadedState: {
    auth: hydrateAuth()
  }
});

injectStore(store);

export type RootState = ReturnType<typeof store.getState>;
export type AppDispatch = typeof store.dispatch;

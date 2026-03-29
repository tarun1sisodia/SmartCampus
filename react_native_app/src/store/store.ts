import { configureStore } from '@reduxjs/toolkit';
import authReducer from './slices/authSlice';
import attendanceReducer from './slices/attendanceSlice';

export const store = configureStore({
  reducer: {
    auth: authReducer,
    attendance: attendanceReducer,
  },
  middleware: (getDefaultMiddleware) =>
    getDefaultMiddleware({
      serializableCheck: false, // For WatermelonDB models if stored (though they shouldn't be directly)
    }),
});

export type RootState = ReturnType<typeof store.getState>;
export type AppDispatch = typeof store.dispatch;

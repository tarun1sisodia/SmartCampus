"use client";

import { useDispatch, useSelector } from "react-redux";
import { RootState, AppDispatch } from "@/lib/store/store";
import { logout } from "@/lib/store/slices/authSlice";
import { clearSessionFlagCookie } from "@/lib/utils/authCookies";

export function useAuth() {
  const dispatch = useDispatch<AppDispatch>();
  const user = useSelector((state: RootState) => state.auth.user);
  const isAuthenticated = useSelector((state: RootState) => state.auth.isAuthenticated);

  return {
    user,
    isAuthenticated,
    logout: async () => {
      await dispatch(logout());
      clearSessionFlagCookie();
    }
  };
}

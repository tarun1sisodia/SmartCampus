import { useSelector, useDispatch } from "react-redux";
import { RootState, AppDispatch } from "@/lib/store/store";
import { logout as logoutAction } from "@/lib/store/slices/authSlice";
import { clearAccessTokenCookie } from "@/lib/utils/authCookies";

export function useAuth() {
  const dispatch = useDispatch<AppDispatch>();
  const { user, isAuthenticated } = useSelector((state: RootState) => state.auth);

  const logout = async () => {
    await dispatch(logoutAction());
    clearAccessTokenCookie();
  };

  return { user, isAuthenticated, logout };
}

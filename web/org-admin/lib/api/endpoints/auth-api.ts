import { axiosClient } from "@/lib/api/axios-client";
import { LoginRequest, LoginResponse } from "@/types/auth";

export async function loginApi(payload: LoginRequest): Promise<LoginResponse> {
  const { data } = await axiosClient.post<{ success: boolean; data: LoginResponse }>("/auth/login", payload);
  return data.data;
}

export async function logoutApi(refreshToken?: string | null): Promise<void> {
  await axiosClient.post("/auth/logout", refreshToken ? { refreshToken } : undefined);
}

export async function refreshTokenApi(refreshToken: string): Promise<{ accessToken: string }> {
  const { data } = await axiosClient.post<{ success: boolean; data: { accessToken: string } }>("/auth/refresh", {
    refreshToken
  });
  return data.data;
}

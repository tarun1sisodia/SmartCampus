import { axiosClient } from "@/lib/api/axios-client";
import { LoginRequest, LoginResponse } from "@/types/auth";

export async function loginApi(payload: LoginRequest): Promise<LoginResponse> {
  const { data } = await axiosClient.post<LoginResponse>("/auth/login", payload);
  return data;
}

export async function logoutApi(): Promise<void> {
  await axiosClient.post("/auth/logout");
}

export async function refreshTokenApi(refreshToken: string): Promise<{ accessToken: string }> {
  const { data } = await axiosClient.post<{ accessToken: string }>("/auth/refresh-token", {
    refreshToken
  });
  return data;
}

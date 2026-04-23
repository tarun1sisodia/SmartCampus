"use client";

import axios from "axios";
import { store } from "@/lib/store/store";
import { clearCredentials, setCredentials } from "@/lib/store/slices/authSlice";

const API_URL = process.env.NEXT_PUBLIC_API_URL ?? "http://localhost:8080";

export const axiosClient = axios.create({
  baseURL: API_URL
});

axiosClient.interceptors.request.use(config => {
  const token = store.getState().auth.accessToken;
  if (token) config.headers.Authorization = `Bearer ${token}`;
  return config;
});

axiosClient.interceptors.response.use(
  response => response,
  async error => {
    const originalRequest = error.config;
    if (error.response?.status === 401 && !originalRequest?._retry) {
      originalRequest._retry = true;
      const refreshToken = store.getState().auth.refreshToken;
      if (!refreshToken) {
        store.dispatch(clearCredentials());
        return Promise.reject(error);
      }

      try {
        const { data } = await axios.post<{ accessToken: string }>(
          `${API_URL}/auth/refresh-token`,
          { refreshToken }
        );
        store.dispatch(
          setCredentials({
            user: store.getState().auth.user,
            accessToken: data.accessToken,
            refreshToken
          })
        );
        return axiosClient(originalRequest);
      } catch (refreshError) {
        store.dispatch(clearCredentials());
        return Promise.reject(refreshError);
      }
    }
    return Promise.reject(error);
  }
);

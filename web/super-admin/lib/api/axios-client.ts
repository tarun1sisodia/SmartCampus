"use client";

import axios from "axios";

let store: any;
export const injectStore = (_store: any) => {
  store = _store;
};

const API_URL = process.env.NEXT_PUBLIC_API_URL ?? "http://localhost:5000/api/v1";

export const axiosClient = axios.create({
  baseURL: API_URL
});

axiosClient.interceptors.request.use(config => {
  if (store) {
    const token = store.getState().auth.accessToken;
    if (token) config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

axiosClient.interceptors.response.use(
  response => response,
  async error => {
    const originalRequest = error.config;
    if (error.response?.status === 401 && !originalRequest?._retry && store) {
      originalRequest._retry = true;
      const refreshToken = store.getState().auth.refreshToken;
      if (!refreshToken) {
        store.dispatch({ type: "auth/clearCredentials" });
        return Promise.reject(error);
      }

      try {
        const { data } = await axios.post<{ success: boolean; data: { accessToken: string; refreshToken?: string } }>(
          `${API_URL}/auth/refresh`,
          { refreshToken }
        );
        store.dispatch({
          type: "auth/setCredentials",
          payload: {
            user: store.getState().auth.user,
            accessToken: data.data.accessToken,
            refreshToken: data.data.refreshToken || refreshToken
          }
        });
        return axiosClient(originalRequest);
      } catch (refreshError) {
        store.dispatch({ type: "auth/clearCredentials" });
        return Promise.reject(refreshError);
      }
    }
    return Promise.reject(error);
  }
);

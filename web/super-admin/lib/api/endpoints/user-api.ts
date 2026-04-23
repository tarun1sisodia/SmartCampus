import { axiosClient } from "@/lib/api/axios-client";
import { AdminUser, UserListParams, UserListResponse } from "@/types/user";

export async function getUsers(params: UserListParams): Promise<UserListResponse> {
  const { data } = await axiosClient.get<UserListResponse>("/users", { params });
  return data;
}

export async function deactivateUser(userId: string): Promise<void> {
  await axiosClient.delete(`/users/${userId}`);
}

export async function resetPassword(userId: string): Promise<void> {
  await axiosClient.post(`/users/${userId}/reset-password`);
}

export async function promoteToSuperAdmin(userId: string): Promise<AdminUser> {
  const { data } = await axiosClient.patch<AdminUser>(`/users/${userId}`, {
    role: "super_admin"
  });
  return data;
}

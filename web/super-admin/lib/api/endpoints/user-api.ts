import { axiosClient } from "@/lib/api/axios-client";
import { AdminUser, UserListParams, UserListResponse } from "@/types/user";

type BackendUser = {
  _id: string;
  name: string;
  email: string;
  role: string;
  isActive: boolean;
  lastLogin?: string | null;
  organisation?: { _id: string; name: string } | null;
};

type BackendListEnvelope = {
  success: boolean;
  data: { data: BackendUser[]; total: number; page: number; limit: number };
};

const mapUser = (user: BackendUser): AdminUser => ({
  id: user._id,
  name: user.name,
  email: user.email,
  role: user.role === "super_admin" ? "super_admin" : "org_admin",
  organisationName: user.organisation?.name ?? null,
  status: user.isActive ? "active" : "inactive",
  lastLogin: user.lastLogin ?? null
});

export async function getUsers(params: UserListParams): Promise<UserListResponse> {
  const query: Record<string, unknown> = { page: params.page, limit: params.limit };
  if (params.role && params.role !== "all") query.role = params.role;

  const { data } = await axiosClient.get<BackendListEnvelope>("/users", { params: query });
  const page = data.data.page ?? 1;
  const limit = data.data.limit ?? 10;
  const total = data.data.total ?? 0;
  return {
    items: (data.data.data ?? []).map(mapUser),
    page,
    totalPages: limit > 0 ? Math.ceil(total / limit) : 1,
    totalItems: total
  };
}

export async function deactivateUser(userId: string): Promise<void> {
  await axiosClient.delete(`/users/${userId}`);
}

export async function resetPassword(userId: string): Promise<void> {
  await axiosClient.post(`/users/${userId}/reset-password`);
}

export async function promoteToSuperAdmin(userId: string): Promise<AdminUser> {
  const { data } = await axiosClient.patch<{ success: boolean; data: BackendUser }>(
    `/users/${userId}`,
    { role: "super_admin" }
  );
  return mapUser(data.data);
}

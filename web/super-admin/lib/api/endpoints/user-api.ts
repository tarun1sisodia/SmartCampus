import { axiosClient } from "@/lib/api/axios-client";
import { AdminUser, UserListParams, UserListResponse } from "@/types/user";

type ApiEnvelope<T> = { success: boolean; data: T };
type BackendList<T> = { data: T[]; total: number; page: number; limit: number };

function unwrap<T>(payload: ApiEnvelope<T> | T): T {
  const data = (payload as ApiEnvelope<T>).data;
  return data !== undefined ? data : (payload as T);
}

function toAdminUser(raw: Record<string, unknown>): AdminUser {
  return {
    id: (raw.id ?? raw._id ?? "").toString(),
    name: (raw.name ?? "").toString(),
    email: (raw.email ?? "").toString(),
    role: (raw.role as AdminUser["role"]) ?? "org_admin",
    organisationName:
      (raw.organisation as Record<string, unknown>)?.name?.toString() ?? null,
    status: (raw.status as AdminUser["status"]) ?? (raw.isActive === false ? "inactive" : "active"),
    lastLogin: raw.lastLogin?.toString() ?? null
  };
}

function toUserListResponse(response: BackendList<AdminUser>): UserListResponse {
  return {
    items: response.data.map(item => toAdminUser(item as Record<string, unknown>)),
    page: response.page,
    totalPages: Math.ceil(response.total / response.limit),
    totalItems: response.total
  };
}

export async function getUsers(params: UserListParams): Promise<UserListResponse> {
  const { data } = await axiosClient.get<ApiEnvelope<BackendList<AdminUser>>>("/users", { params });
  return toUserListResponse(unwrap(data));
}

export async function deactivateUser(userId: string): Promise<void> {
  await axiosClient.delete(`/users/${userId}`);
}

export async function resetPassword(userId: string): Promise<void> {
  await axiosClient.post(`/users/${userId}/reset-password`);
}

export async function promoteToSuperAdmin(userId: string): Promise<AdminUser> {
  const { data } = await axiosClient.patch<ApiEnvelope<AdminUser>>(`/users/${userId}`, {
    role: "super_admin"
  });
  return toAdminUser(unwrap(data) as Record<string, unknown>);
}

import { axiosClient } from "@/lib/api/axios-client";
import { InviteTeacherPayload, Teacher, TeachersResponse } from "@/types/user";

type ApiEnvelope<T> = { success: boolean; data: T };
type BackendList<T> = { data: T[]; total: number; page: number; limit: number };

function unwrap<T>(payload: ApiEnvelope<T> | T): T {
  const data = (payload as ApiEnvelope<T>).data;
  return data !== undefined ? data : (payload as T);
}

function toTeacher(raw: Record<string, unknown>): Teacher {
  return {
    id: (raw.id ?? raw._id ?? "").toString(),
    name: (raw.name ?? "").toString(),
    email: (raw.email ?? "").toString(),
    isActive: raw.isActive !== false,
    lastLogin: raw.lastLogin?.toString() ?? null
  };
}

function toTeachersResponse(response: BackendList<Teacher>): TeachersResponse {
  return {
    items: response.data.map(item => toTeacher(item as Record<string, unknown>)),
    page: response.page,
    totalPages: Math.ceil(response.total / response.limit),
    totalItems: response.total
  };
}

export async function getTeachers(params?: {
  page?: number;
  limit?: number;
}): Promise<TeachersResponse> {
  const { data } = await axiosClient.get<ApiEnvelope<BackendList<Teacher>>>("/users/teachers", { params });
  return toTeachersResponse(unwrap(data));
}

export async function inviteTeacher(payload: InviteTeacherPayload): Promise<Teacher> {
  const { data } = await axiosClient.post<ApiEnvelope<{ message: string; userId: string }>>("/users/invite", {
    name: payload.name,
    email: payload.email,
    role: "teacher"
  });
  return unwrap(data) as unknown as Teacher;
}

export async function deactivateTeacher(userId: string): Promise<void> {
  await axiosClient.delete(`/users/${userId}`);
}

export async function resendInvite(userId: string): Promise<void> {
  await axiosClient.post(`/users/${userId}/resend`);
}

import { axiosClient } from "@/lib/api/axios-client";
import { InviteTeacherPayload, Teacher, TeachersResponse } from "@/types/user";

type BackendUser = {
  _id: string;
  name: string;
  email: string;
  isActive: boolean;
  lastLogin?: string | null;
};

type BackendListEnvelope = {
  success: boolean;
  data: { data: BackendUser[]; total: number; page: number; limit: number };
};

const mapTeacher = (user: BackendUser): Teacher => ({
  id: user._id,
  name: user.name,
  email: user.email,
  isActive: user.isActive,
  lastLogin: user.lastLogin ?? null
});

export async function getTeachers(params?: {
  page?: number;
  limit?: number;
}): Promise<TeachersResponse> {
  const { data } = await axiosClient.get<BackendListEnvelope>("/users/teachers", { params });
  const page = data.data.page ?? 1;
  const limit = data.data.limit ?? 10;
  const total = data.data.total ?? 0;
  return {
    items: (data.data.data ?? []).map(mapTeacher),
    page,
    totalPages: limit > 0 ? Math.ceil(total / limit) : 1,
    totalItems: total
  };
}

export async function inviteTeacher(payload: InviteTeacherPayload): Promise<void> {
  // Backend: POST /users/invite → { message, userId }
  await axiosClient.post("/users/invite", { ...payload, role: "teacher" });
}

export async function deactivateTeacher(userId: string): Promise<void> {
  await axiosClient.delete(`/users/${userId}`);
}

export async function resendInvite(userId: string): Promise<void> {
  await axiosClient.post(`/users/${userId}/resend-invite`);
}

import { axiosClient } from "@/lib/api/axios-client";
import { InviteTeacherPayload, Teacher, TeachersResponse } from "@/types/user";

export async function getTeachers(params?: {
  page?: number;
  limit?: number;
}): Promise<TeachersResponse> {
  const { data } = await axiosClient.get<TeachersResponse>("/users/teachers", { params });
  return data;
}

export async function inviteTeacher(payload: InviteTeacherPayload): Promise<Teacher> {
  const { data } = await axiosClient.post<Teacher>("/users/invite", payload);
  return data;
}

export async function deactivateTeacher(userId: string): Promise<void> {
  await axiosClient.delete(`/users/${userId}`);
}

export async function resendInvite(userId: string): Promise<void> {
  await axiosClient.post(`/users/${userId}/resend-invite`);
}

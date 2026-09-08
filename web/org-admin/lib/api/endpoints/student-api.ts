import { axiosClient } from "@/lib/api/axios-client";
import { StudentImportResult } from "@/types/student";

type ApiEnvelope<T> = { success: boolean; data: T };

export async function importStudents(file: File): Promise<StudentImportResult> {
  const formData = new FormData();
  formData.append("file", file);

  const { data } = await axiosClient.post<ApiEnvelope<StudentImportResult>>("/students/import", formData, {
    headers: { "Content-Type": "multipart/form-data" }
  });
  return data.data;
}

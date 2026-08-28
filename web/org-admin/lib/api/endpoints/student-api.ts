import { axiosClient } from "@/lib/api/axios-client";
import { StudentImportResult } from "@/types/student";

export async function importStudents(file: File): Promise<StudentImportResult> {
  const formData = new FormData();
  formData.append("file", file);

  const { data } = await axiosClient.post<{ success: boolean; data: StudentImportResult }>(
    "/students/import",
    formData,
    { headers: { "Content-Type": "multipart/form-data" } }
  );
  // Backend responds { success, data: { total, succeeded, failed, errors } }.
  return data.data;
}

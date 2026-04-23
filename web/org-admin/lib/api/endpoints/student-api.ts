import { axiosClient } from "@/lib/api/axios-client";
import { StudentImportResult } from "@/types/student";

export async function importStudents(file: File): Promise<StudentImportResult> {
  const formData = new FormData();
  formData.append("file", file);

  const { data } = await axiosClient.post<StudentImportResult>("/students/import", formData, {
    headers: { "Content-Type": "multipart/form-data" }
  });
  return data;
}

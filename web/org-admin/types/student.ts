export type StudentImportResult = {
  successCount: number;
  failureCount: number;
  errors: Array<{ row: number; message: string }>;
};

export type StudentImportResult = {
  total: number;
  succeeded: number;
  failed: number;
  errors: Array<{ rollNumber?: string; error: string }>;
};

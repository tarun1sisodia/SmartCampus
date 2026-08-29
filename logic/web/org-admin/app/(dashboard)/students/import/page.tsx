// =============================================================
// (dashboard)/students/import/page.tsx (org-admin)  ->  ALGORITHM ONLY
// (source: web/org-admin/app/(dashboard)/students/import/page.tsx)
// =============================================================

// CSV import flow:
//   pick file -> parse LOCALLY in browser (papaparse) -> preview rows in a table + row count
//   import button -> importStudents mutation (multipart POST /students/import)
//   success -> toast '{succeeded} imported, {failed} failed' + errors list from backend
//   parse failure -> inline error, upload blocked

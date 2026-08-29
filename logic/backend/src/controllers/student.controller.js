// =============================================================
// student.controller.js  ->  ALGORITHM ONLY (source: backend/src/controllers/student.controller.js)
// =============================================================

// bulkImport : uploaded file buffer -> csvParser.parseCSV -> service.bulkImport (transaction)
// list : filters + pagination; when ?sessionId given -> resolve that session's course/semester/section
//   so the Flutter carousel gets exactly that class's students
// create / getById / update : org-scoped (super admin can pass organisationId)
// deleteFn : SOFT delete (isActive=false)
// uploadPhoto / deletePhoto : multer buffer -> cloudinary via service (scoped)

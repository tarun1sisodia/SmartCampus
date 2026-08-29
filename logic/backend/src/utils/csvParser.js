// =============================================================
// csvParser.js  ->  ALGORITHM ONLY (source: backend/src/utils/csvParser.js)
// Streaming CSV parse with hard limits.
// =============================================================

// parseCSV(buffer) -> Promise<rows[]> :
//   buffer > 5MB -> reject 413 'CSV file too large'
//   stream buffer through csv-parser, collecting row objects
//   more than CSV_MAX_ROWS (default 5000) rows -> destroy stream + reject 413
//   stream error -> reject

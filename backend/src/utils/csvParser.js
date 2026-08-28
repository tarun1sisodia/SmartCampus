import csv from 'csv-parser';
import { Readable } from 'stream';

const MAX_ROWS = Number(process.env.CSV_MAX_ROWS || 5000);
const MAX_BUFFER = 5 * 1024 * 1024; // 5MB

export const parseCSV = (buffer) => {
  return new Promise((resolve, reject) => {
    if (buffer && buffer.length > MAX_BUFFER) {
      return reject(Object.assign(new Error('CSV file too large'), { status: 413 }));
    }

    const results = [];
    const stream = Readable.from(buffer);

    stream
      .pipe(csv())
      .on('data', (data) => {
        if (results.length >= MAX_ROWS) {
          stream.destroy();
          reject(Object.assign(new Error(`CSV exceeds the maximum of ${MAX_ROWS} rows`), { status: 413 }));
          return;
        }
        results.push(data);
      })
      .on('end', () => resolve(results))
      .on('error', (error) => reject(error));
  });
};

export default { parseCSV };

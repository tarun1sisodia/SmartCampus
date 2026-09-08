import path from 'path';
import dotenv from 'dotenv';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Always load the base .env first, then overlay environment-specific values.
const envDir = path.join(__dirname, '../../');
dotenv.config({ path: path.join(envDir, '.env') });
if (process.env.NODE_ENV) {
  dotenv.config({ path: path.join(envDir, `.env.${process.env.NODE_ENV}`), override: true });
}

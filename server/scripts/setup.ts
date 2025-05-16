import fs from 'fs';
import path from 'path';
import crypto from 'crypto';

const rootDir = path.join(__dirname, '..');

// Ensure required directories exist
const createDirectories = () => {
  const directories = [
    'uploads',
    'uploads/images',
    'uploads/csv',
    'logs'
  ];

  directories.forEach(dir => {
    const dirPath = path.join(rootDir, dir);
    if (!fs.existsSync(dirPath)) {
      fs.mkdirSync(dirPath, { recursive: true });
      console.log(`Created directory: ${dir}`);
    }
  });
};

// Create example .env file if it doesn't exist
const createEnvFile = () => {
  const envPath = path.join(rootDir, '.env');
  if (!fs.existsSync(envPath)) {
    const jwtSecret = crypto.randomBytes(32).toString('hex');
    
    const envContent = `# Server Configuration
PORT=3000
NODE_ENV=development

# Supabase Configuration
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
SUPABASE_SERVICE_ROLE_KEY=your_supabase_service_role_key

# JWT Configuration
JWT_SECRET=${jwtSecret}
JWT_EXPIRES_IN=24h

# Rate Limiting
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100

# Logging
LOG_LEVEL=debug
`;

    fs.writeFileSync(envPath, envContent);
    console.log('Created .env file with example configuration');
  }
};

// Create example database schema file
const createSchemaFile = () => {
  const schemaDir = path.join(rootDir, 'src/db');
  if (!fs.existsSync(schemaDir)) {
    fs.mkdirSync(schemaDir, { recursive: true });
  }
  
  const schemaPath = path.join(schemaDir, 'schema.example.sql');
  if (!fs.existsSync(schemaPath)) {
    const content = fs.readFileSync(path.join(rootDir, 'src/db/schema.sql'), 'utf8');
    fs.writeFileSync(schemaPath, content);
    console.log('Created example database schema file');
  }
};

// Main setup function
const setup = () => {
  console.log('Starting setup...');
  
  try {
    createDirectories();
    createEnvFile();
    createSchemaFile();
    
    console.log('\nSetup completed successfully!');
    console.log('\nNext steps:');
    console.log('1. Update the .env file with your Supabase credentials');
    console.log('2. Execute the database schema in your Supabase SQL editor');
    console.log('3. Run "npm run dev" to start the development server');
  } catch (error) {
    console.error('Error during setup:', error);
    process.exit(1);
  }
};

setup();

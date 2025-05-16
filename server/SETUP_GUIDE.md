# SmartCampus Server Setup Guide

## Project Structure
```
server/
├── src/
│   ├── config/          # Configuration management
│   ├── controllers/     # Request handlers
│   ├── db/             # Database schemas and migrations
│   ├── middleware/     # Express middleware
│   ├── models/         # Data models
│   ├── routes/         # API routes
│   ├── services/       # Business logic
│   ├── types/          # TypeScript type definitions
│   ├── utils/          # Utility functions
│   └── index.ts        # Application entry point
├── scripts/            # Setup and utility scripts
├── uploads/            # File upload directory
│   ├── images/         # Profile pictures
│   └── csv/            # CSV imports/exports
├── logs/              # Application logs
└── __tests__/         # Test files
```

## Implemented Features
1. Authentication System
   - User registration and login
   - Role-based access control
   - JWT token management

2. Course Management
   - CRUD operations for courses
   - Validation and error handling

3. Subject Management
   - CRUD operations for subjects
   - Course relationship handling

4. Student Management
   - Student profile management
   - Profile picture handling
   - CSV import/export functionality

5. Attendance System
   - Session creation and management
   - Real-time attendance marking
   - Attendance reports and analytics

6. Security Features
   - Rate limiting
   - CORS configuration
   - Request validation
   - Error handling

## Next Steps

### 1. Supabase Setup
1. Create a new Supabase project at https://supabase.com
2. Navigate to your project settings to get:
   - Project URL
   - API Keys (anon key and service_role key)
3. Execute the database schema:
   - Copy the contents of `src/db/schema.sql`
   - Run it in the Supabase SQL editor

### 2. Environment Configuration
Update the `.env` file with your Supabase credentials:
```env
SUPABASE_URL=your_project_url
SUPABASE_ANON_KEY=your_anon_key
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key
```

### 3. Storage Setup
1. Create the following storage buckets in Supabase:
   - `profile-pictures` for student profile images
   - `documents` for any additional files

### 4. Testing
1. Run the test suite:
   ```bash
   npm test
   ```
2. Check test coverage:
   ```bash
   npm run test:coverage
   ```

### 5. Development
1. Start the development server:
   ```bash
   npm run dev
   ```
2. Access the API at `http://localhost:3000/api/v1`
3. Use the health check endpoint to verify the server is running:
   ```bash
   curl http://localhost:3000/api/v1/health
   ```

### 6. API Documentation
Consider adding detailed API documentation using:
1. Swagger/OpenAPI
2. Postman collection
3. API blueprint

### 7. Frontend Integration
The server is ready to be integrated with the Flutter frontend:
1. Update the Flutter app's environment configuration with the API URL
2. Use the Supabase Flutter SDK with the same credentials
3. Implement the API client services in the Flutter app

## Common Issues and Solutions

### 1. Database Connection
If you can't connect to Supabase:
- Verify your credentials in .env
- Check if your IP is allowed in Supabase dashboard
- Ensure the database schema was executed successfully

### 2. File Uploads
If file uploads aren't working:
- Check if upload directories exist
- Verify Supabase storage bucket permissions
- Ensure proper file size limits in configurations

### 3. Authentication
If authentication issues occur:
- Verify JWT configuration
- Check role assignments in Supabase
- Ensure proper token handling in requests

## Support and Resources
- Supabase Documentation: https://supabase.com/docs
- Express.js Guide: https://expressjs.com/
- TypeScript Documentation: https://www.typescriptlang.org/docs/

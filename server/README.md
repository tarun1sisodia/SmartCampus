# SmartCampus Server

Backend server for the SmartCampus Attendance Management System.

## Features

- User authentication and authorization
- Course management
- Subject management
- Student management with profile pictures
- Attendance tracking and reporting
- CSV import/export functionality
- Real-time updates using Supabase

## Prerequisites

- Node.js (v14 or higher)
- npm (v6 or higher)
- Supabase account and project

## Setup

1. Clone the repository
2. Install dependencies:
   ```bash
   npm install
   ```
3. Run the setup script:
   ```bash
   npm run setup
   ```
4. Update the `.env` file with your Supabase credentials
5. Execute the database schema in your Supabase SQL editor (found in `src/db/schema.sql`)

## Development

Start the development server:
```bash
npm run dev
```

## Scripts

- `npm run dev` - Start development server
- `npm run build` - Build the project
- `npm start` - Start production server
- `npm run setup` - Run initial setup
- `npm run lint` - Run ESLint
- `npm run lint:fix` - Fix ESLint issues
- `npm test` - Run tests
- `npm run test:watch` - Run tests in watch mode
- `npm run test:coverage` - Run tests with coverage report

## API Documentation

### Authentication
- POST `/api/v1/auth/signup` - Register a new user
- POST `/api/v1/auth/login` - Login user
- POST `/api/v1/auth/logout` - Logout user

### Courses
- GET `/api/v1/courses` - Get all courses
- GET `/api/v1/courses/:id` - Get course by ID
- POST `/api/v1/courses` - Create new course
- PUT `/api/v1/courses/:id` - Update course
- DELETE `/api/v1/courses/:id` - Delete course

### Subjects
- GET `/api/v1/subjects` - Get all subjects
- GET `/api/v1/subjects/:id` - Get subject by ID
- GET `/api/v1/subjects/course/:courseId` - Get subjects by course
- POST `/api/v1/subjects` - Create new subject
- PUT `/api/v1/subjects/:id` - Update subject
- DELETE `/api/v1/subjects/:id` - Delete subject

### Students
- GET `/api/v1/students/course/:courseId` - Get students by course
- GET `/api/v1/students/:id` - Get student by ID
- POST `/api/v1/students` - Create new student
- PUT `/api/v1/students/:id` - Update student
- DELETE `/api/v1/students/:id` - Delete student
- POST `/api/v1/students/import/:courseId` - Import students from CSV
- GET `/api/v1/students/export/:courseId` - Export students to CSV

### Attendance
- POST `/api/v1/attendance/sessions` - Create attendance session
- GET `/api/v1/attendance/sessions/:id` - Get session by ID
- GET `/api/v1/attendance/sessions/subject/:subjectId` - Get sessions by subject
- POST `/api/v1/attendance/sessions/:sessionId/students/:studentId` - Mark attendance
- GET `/api/v1/attendance/sessions/:sessionId/records` - Get session attendance records
- GET `/api/v1/attendance/students/:studentId` - Get student attendance records
- GET `/api/v1/attendance/reports/subject/:subjectId` - Generate attendance report

## License

ISC

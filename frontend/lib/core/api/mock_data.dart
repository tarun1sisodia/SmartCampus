class MockData {
  static const Map<String, dynamic> loginResponse = {
    "status": "success",
    "data": {
      "user": {
        "_id": "60d0fe4f5311236168a109ca",
        "name": "Jane Smith",
        "email": "jane.smith@example.com",
        "role": "teacher",
        "department": "Computer Science",
        "profilePhotoUrl": "https://i.pravatar.cc/150?u=jane"
      },
      "token": "mock-jwt-token-12345"
    }
  };

  static const Map<String, dynamic> meResponse = {
    "status": "success",
    "data": {
      "_id": "60d0fe4f5311236168a109ca",
      "name": "Jane Smith",
      "email": "jane.smith@example.com",
      "role": "teacher",
      "department": "Computer Science",
      "profilePhotoUrl": "https://i.pravatar.cc/150?u=jane"
    }
  };

  static const Map<String, dynamic> todaySessions = {
    "status": "success",
    "data": [
      {
        "_id": "sess_001",
        "courseId": {"_id": "c_1", "name": "Software Engineering", "code": "CS401"},
        "date": "2024-10-15T00:00:00.000Z",
        "startTime": "09:00",
        "endTime": "10:30",
        "room": "Room 101",
        "type": "Lecture",
        "status": "scheduled",
        "totalStudents": 45,
        "teacher": "60d0fe4f5311236168a109ca"
      },
      {
        "_id": "sess_002",
        "courseId": {"_id": "c_2", "name": "Database Systems", "code": "CS402"},
        "date": "2024-10-15T00:00:00.000Z",
        "startTime": "11:00",
        "endTime": "12:30",
        "room": "Lab 3",
        "type": "Lab",
        "status": "completed",
        "totalStudents": 30,
        "teacher": "60d0fe4f5311236168a109ca"
      }
    ]
  };

  static Map<String, dynamic> getSessionDetails(String sessionId) {
    return {
      "status": "success",
      "data": {
        "_id": sessionId,
        "courseId": {"_id": "c_1", "name": "Software Engineering", "code": "CS401"},
        "date": "2024-10-15T00:00:00.000Z",
        "startTime": "09:00",
        "endTime": "10:30",
        "room": "Room 101",
        "type": "Lecture",
        "status": "scheduled",
        "totalStudents": 45,
        "teacher": "60d0fe4f5311236168a109ca"
      }
    };
  }

  static const Map<String, dynamic> sessionAttendance = {
    "status": "success",
    "data": [
      {
        "_id": "att_001",
        "student": {"_id": "stu_01", "name": "Alice Johnson", "rollNumber": "CS2001", "profilePhotoUrl": "https://i.pravatar.cc/150?u=alice"},
        "status": "present",
        "timestamp": "2024-10-15T09:05:00.000Z",
        "remarks": ""
      },
      {
        "_id": "att_002",
        "student": {"_id": "stu_02", "name": "Bob Williams", "rollNumber": "CS2002", "profilePhotoUrl": "https://i.pravatar.cc/150?u=bob"},
        "status": "absent",
        "timestamp": null,
        "remarks": ""
      },
      {
        "_id": "att_003",
        "student": {"_id": "stu_03", "name": "Charlie Brown", "rollNumber": "CS2003", "profilePhotoUrl": "https://i.pravatar.cc/150?u=charlie"},
        "status": "present",
        "timestamp": "2024-10-15T09:06:00.000Z",
        "remarks": "Late"
      }
    ]
  };

  static const Map<String, dynamic> teacherAnalytics = {
    "status": "success",
    "data": {
      "totalSessions": 120,
      "completedSessions": 115,
      "averageAttendance": 88.5,
      "monthlyStats": [
        {"month": "January", "attendancePercentage": 85},
        {"month": "February", "attendancePercentage": 89},
        {"month": "March", "attendancePercentage": 92},
        {"month": "April", "attendancePercentage": 88}
      ],
      "coursePerformance": [
        {"courseName": "Software Engineering", "attendancePercentage": 91},
        {"courseName": "Database Systems", "attendancePercentage": 86}
      ]
    }
  };

  static Map<String, dynamic> getStudentDetails(String studentId) {
    return {
      "status": "success",
      "data": {
        "_id": studentId,
        "name": "Alice Johnson",
        "email": "alice@student.example.com",
        "rollNumber": "CS2001",
        "department": "Computer Science",
        "semester": 6,
        "overallAttendance": 92.5,
        "profilePhotoUrl": "https://i.pravatar.cc/150?u=alice",
        "courses": [
          {"courseName": "Software Engineering", "attendance": 95},
          {"courseName": "Database Systems", "attendance": 90}
        ]
      }
    };
  }
}

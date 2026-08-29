// =============================================================
// student_profile_screen.dart  ->  ALGORITHM ONLY
// (source: frontend/lib/features/student/views/student_profile_screen.dart)
// =============================================================

// class StudentProfileScreen(studentId) :

// build :
//   BlocProvider StudentProfileBloc -> dispatch LoadStudentProfile(studentId)
//   BlocBuilder :
//     loaded :
//       header: avatar + name + roll number + course/semester/section
//       stats row: _buildStat(label, value, color) -> present / absent / late counts
//       info list: _buildInfoTile(label, value) -> email, contact, parent contact, address, enrollment year
//     loading -> spinner ; error -> error text

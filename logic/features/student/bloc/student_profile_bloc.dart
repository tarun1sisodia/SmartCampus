// =============================================================
// student_profile_bloc.dart  ->  ALGORITHM ONLY
// (source: frontend/lib/features/student/bloc/student_profile_bloc.dart)
// =============================================================

// event:  LoadStudentProfile(studentId)
// states: Initial | Loading | Loaded(student, summary) | Error(message)

// class StudentProfileBloc(StudentRepository) :
//   _onLoadStudentProfile :
//     emit loading
//     fetch student details + attendance summary in parallel-ish sequence
//     emit Loaded(student, summary); error -> emit Error

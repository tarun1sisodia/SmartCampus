// =============================================================
// carousel_attendance_screen.dart  ->  ALGORITHM ONLY
// (source: frontend/lib/features/attendance/views/carousel_attendance_screen.dart)
// Swipe-card attendance marking (one student per page).
// =============================================================

// class CarouselAttendanceScreen(sessionId) :

// initState() : dispatch LoadStudents(sessionId)
//   _pageController + _currentIndex + _draftStatuses map {studentId -> chosen status}

// build :
//   BlocBuilder<AttendanceBloc, AttendanceState> :
//     loading -> spinner ; error -> retry widget (re-dispatch LoadStudents)
//     AttendanceMarked/OfflineSaved state -> auto push /attendance/summary/<sessionId>
//     loaded :
//       header 'Student i of N - Marked x/N' (x = draft count)
//       PageView of StudentCarouselCard (one student per swipe) :
//         status buttons (present/absent/late) -> save status in _draftStatuses
//         auto-advance to the next student after 300 ms (unless last)
//         tap card -> push /student/<id>
//       bottom bar: prev / SUBMIT ALL / next arrows
//         SUBMIT ALL -> merge drafts into records -> dispatch MarkAttendance(sessionId, records)

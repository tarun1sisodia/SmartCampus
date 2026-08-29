// =============================================================
// session_model.dart  ->  ALGORITHM ONLY (source: frontend/lib/features/home/models/session_model.dart)
// =============================================================

// class SessionModel (Equatable) :
//   fields: id, subjectName, section, courseId, topic?, isHoliday,
//           startTime, endTime?, totalStudents, presentCount?, status('scheduled'|'ongoing'|'completed')

// fromJson(json) :
//   normalize keys (below)
//   baseDate = parse 'date' (fallback now, toLocal)
//   combineDateTime(date, 'HH:mm' string) -> merge date + time into one DateTime
//     (no colon in time -> just date; parse error -> just date)
//   build model: startTime = combine(baseDate, startTime), endTime = combine(baseDate, endTime) if present
//   defaults: status 'scheduled', totalStudents 0, isHoliday false

// _normalizeJson(json) : id <- _id|id|sessionId ; subjectName <- subjectName|subject.name ;
//   section <- section.name|section ; courseId <- courseId|course.id|course._id ; isHoliday <- isHoliday|is_holiday

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/attendance_record_model.dart';
import 'attendance_repository.dart';
import '../../../core/services/connectivity_service.dart';
import '../../../core/database/app_database.dart';

// Events
abstract class AttendanceEvent extends Equatable {
  const AttendanceEvent();
  @override
  List<Object?> get props => [];
}

class AttendanceLoadRequested extends AttendanceEvent {
  final String sessionId;
  const AttendanceLoadRequested(this.sessionId);
  @override
  List<Object?> get props => [sessionId];
}

class AttendanceMarkRequested extends AttendanceEvent {
  final String sessionId;
  final String studentId;
  final String status;
  final String? remarks;

  const AttendanceMarkRequested({
    required this.sessionId,
    required this.studentId,
    required this.status,
    this.remarks,
  });

  @override
  List<Object?> get props => [sessionId, studentId, status, remarks];
}

// States
abstract class AttendanceState extends Equatable {
  const AttendanceState();
  @override
  List<Object?> get props => [];
}

class AttendanceInitial extends AttendanceState {}
class AttendanceLoading extends AttendanceState {}
class AttendanceLoaded extends AttendanceState {
  final List<AttendanceRecordModel> students;
  final int markedCount;
  const AttendanceLoaded(this.students, this.markedCount);
  @override
  List<Object?> get props => [students, markedCount];
}
class AttendanceMarkSuccess extends AttendanceState {}
class AttendanceOfflineSaved extends AttendanceState {
  final String message;
  const AttendanceOfflineSaved(this.message);
  @override
  List<Object?> get props => [message];
}
class AttendanceError extends AttendanceState {
  final String message;
  const AttendanceError(this.message);
  @override
  List<Object?> get props => [message];
}

// Bloc
class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  final AttendanceRepository _repository;
  final ConnectivityService _connectivityService;
  final AppDatabase _db;

  AttendanceBloc(this._repository, this._connectivityService, this._db) : super(AttendanceInitial()) {
    on<AttendanceLoadRequested>(_onLoadRequested);
    on<AttendanceMarkRequested>(_onMarkRequested);
  }

  Future<void> _onLoadRequested(AttendanceLoadRequested event, Emitter<AttendanceState> emit) async {
    emit(AttendanceLoading());
    try {
      final students = await _repository.fetchStudentsForSession(event.sessionId);
      final markedCount = students.where((s) => s.status != 'pending').length;
      emit(AttendanceLoaded(students, markedCount));
    } catch (e) {
      emit(AttendanceError('Failed to load students: ${e.toString()}'));
    }
  }

  Future<void> _onMarkRequested(AttendanceMarkRequested event, Emitter<AttendanceState> emit) async {
    if (_connectivityService.isOnline) {
      try {
        await _repository.markAttendance(
          sessionId: event.sessionId,
          studentId: event.studentId,
          status: event.status,
          remarks: event.remarks,
        );
        emit(AttendanceMarkSuccess());
        // Refresh list
        add(AttendanceLoadRequested(event.sessionId));
      } catch (e) {
        emit(AttendanceError('Failed to mark attendance: ${e.toString()}'));
      }
    } else {
      try {
        await _db.insert('pending_attendance', {
          'sessionId': event.sessionId,
          'studentId': event.studentId,
          'status': event.status,
          'remarks': event.remarks,
          'timestamp': DateTime.now().toIso8601String(),
          'synced': 0,
        });
        emit(const AttendanceOfflineSaved('Attendance saved offline. It will sync automatically when online.'));
        // Local refresh
        if (state is AttendanceLoaded) {
          final currentStudents = (state as AttendanceLoaded).students;
          final updatedStudents = currentStudents.map((s) {
            if (s.studentId == event.studentId) {
              return s.copyWith(status: event.status);
            }
            return s;
          }).toList();
          final markedCount = updatedStudents.where((s) => s.status != 'pending').length;
          emit(AttendanceLoaded(updatedStudents, markedCount));
        }
      } catch (e) {
        emit(AttendanceError('Database error: ${e.toString()}'));
      }
    }
  }
}

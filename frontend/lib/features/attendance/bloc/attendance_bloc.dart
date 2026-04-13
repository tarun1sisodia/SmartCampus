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

class LoadStudents extends AttendanceLoadRequested {
  const LoadStudents(super.sessionId);
}

class AttendanceMarkRequested extends AttendanceEvent {
  final String sessionId;
  final List<AttendanceRecordModel> records;

  const AttendanceMarkRequested({
    required this.sessionId,
    required this.records,
  });

  @override
  List<Object?> get props => [sessionId, records];
}

class MarkAttendance extends AttendanceMarkRequested {
  const MarkAttendance({
    required super.sessionId,
    required super.records,
  });
}

class SyncPending extends AttendanceEvent {}

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
class AttendanceMarked extends AttendanceState {
  final List<AttendanceRecordModel> records;
  const AttendanceMarked(this.records);

  @override
  List<Object?> get props => [records];
}
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
    on<SyncPending>(_onSyncPending);
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
          records: event.records,
        );
        emit(AttendanceMarked(event.records));
        add(AttendanceLoadRequested(event.sessionId));
      } catch (e) {
        emit(AttendanceError('Failed to mark attendance: ${e.toString()}'));
      }
    } else {
      try {
        for (final record in event.records.where((r) => r.status != 'pending')) {
          await _db.insert('pending_attendance', {
            'sessionId': event.sessionId,
            'studentId': record.studentId,
            'status': record.status,
            'remarks': null,
            'timestamp': DateTime.now().toUtc().toIso8601String(),
            'synced': 0,
          });
        }
        emit(const AttendanceOfflineSaved('Attendance saved offline. It will sync automatically when online.'));
        emit(AttendanceMarked(event.records));
        add(AttendanceLoadRequested(event.sessionId));
      } catch (e) {
        emit(AttendanceError('Database error: ${e.toString()}'));
      }
    }
  }

  Future<void> _onSyncPending(SyncPending event, Emitter<AttendanceState> emit) async {
    final pending = await _db.query(
      'pending_attendance',
      where: 'synced = ?',
      whereArgs: [0],
    );
    if (pending.isEmpty) return;
    try {
      await _repository.syncOffline(pending);
      for (final record in pending) {
        await _db.delete(
          'pending_attendance',
          where: 'id = ?',
          whereArgs: [record['id']],
        );
      }
    } catch (_) {
      // keep pending rows for next attempt
    }
  }
}

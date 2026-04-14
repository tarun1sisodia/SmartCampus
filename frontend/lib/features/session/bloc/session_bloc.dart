import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_campus/features/session/bloc/session_event.dart';
import 'package:smart_campus/features/session/bloc/session_state.dart';
import 'package:smart_campus/features/session/bloc/session_repository.dart';

class SessionBloc extends Bloc<SessionEvent, SessionState> {
  final SessionRepository _repository;

  SessionBloc(this._repository) : super(SessionInitial()) {
    on<SessionHistoryRequested>(_onHistoryRequested);
    on<SessionDetailsRequested>(_onDetailsRequested);
  }

  Future<void> _onHistoryRequested(
    SessionHistoryRequested event,
    Emitter<SessionState> emit,
  ) async {
    emit(SessionLoading());
    try {
      final sessions = await _repository.fetchSessionHistory(
        teacherId: event.teacherId,
        startDate: event.startDate,
        endDate: event.endDate,
      );
      emit(SessionHistoryLoaded(sessions));
    } catch (e) {
      emit(SessionError(e.toString()));
    }
  }

  Future<void> _onDetailsRequested(
    SessionDetailsRequested event,
    Emitter<SessionState> emit,
  ) async {
    emit(SessionLoading());
    try {
      final sessionDetail =
          await _repository.fetchSessionDetails(event.sessionId);
      emit(SessionDetailsLoaded(sessionDetail));
    } catch (e) {
      emit(SessionError(e.toString()));
    }
  }
}

import 'package:equatable/equatable.dart';
import 'package:smart_campus/features/home/models/session_model.dart';
import 'package:smart_campus/features/session/models/session_detail_model.dart';

abstract class SessionState extends Equatable {
  const SessionState();

  @override
  List<Object?> get props => [];
}

class SessionInitial extends SessionState {}

class SessionLoading extends SessionState {}

class SessionHistoryLoaded extends SessionState {
  final List<SessionModel> sessions;

  const SessionHistoryLoaded(this.sessions);

  @override
  List<Object?> get props => [sessions];
}

class SessionDetailsLoaded extends SessionState {
  final SessionDetailModel sessionDetail;

  const SessionDetailsLoaded(this.sessionDetail);

  @override
  List<Object?> get props => [sessionDetail];
}

class SessionError extends SessionState {
  final String message;

  const SessionError(this.message);

  @override
  List<Object?> get props => [message];
}

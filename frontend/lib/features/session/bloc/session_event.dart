import 'package:equatable/equatable.dart';

abstract class SessionEvent extends Equatable {
  const SessionEvent();

  @override
  List<Object?> get props => [];
}

class SessionHistoryRequested extends SessionEvent {}

class SessionDetailsRequested extends SessionEvent {
  final String sessionId;

  const SessionDetailsRequested(this.sessionId);

  @override
  List<Object?> get props => [sessionId];
}

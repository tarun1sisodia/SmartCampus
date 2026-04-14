import 'package:equatable/equatable.dart';

abstract class SessionEvent extends Equatable {
  const SessionEvent();

  @override
  List<Object?> get props => [];
}

class SessionHistoryRequested extends SessionEvent {
  const SessionHistoryRequested({
    required this.teacherId,
    this.startDate,
    this.endDate,
  });

  final String teacherId;
  final DateTime? startDate;
  final DateTime? endDate;

  @override
  List<Object?> get props => [teacherId, startDate, endDate];
}

class SessionDetailsRequested extends SessionEvent {
  final String sessionId;

  const SessionDetailsRequested(this.sessionId);

  @override
  List<Object?> get props => [sessionId];
}

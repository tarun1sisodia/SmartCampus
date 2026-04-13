import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/teacher_stats_model.dart';
import 'analytics_repository.dart';

// Events
abstract class AnalyticsEvent extends Equatable {
  const AnalyticsEvent();
  @override
  List<Object?> get props => [];
}

class AnalyticsLoadRequested extends AnalyticsEvent {
  final String teacherId;
  final DateTime? startDate;
  final DateTime? endDate;

  const AnalyticsLoadRequested({
    required this.teacherId,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [teacherId, startDate, endDate];
}

// States
abstract class AnalyticsState extends Equatable {
  const AnalyticsState();
  @override
  List<Object?> get props => [];
}

class AnalyticsInitial extends AnalyticsState {}
class AnalyticsLoading extends AnalyticsState {}
class AnalyticsLoaded extends AnalyticsState {
  final TeacherStatsModel stats;
  const AnalyticsLoaded(this.stats);
  @override
  List<Object?> get props => [stats];
}
class AnalyticsError extends AnalyticsState {
  final String message;
  const AnalyticsError(this.message);
  @override
  List<Object?> get props => [message];
}

// Bloc
class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  final AnalyticsRepository _repository;

  AnalyticsBloc(this._repository) : super(AnalyticsInitial()) {
    on<AnalyticsLoadRequested>(_onLoadRequested);
  }

  Future<void> _onLoadRequested(AnalyticsLoadRequested event, Emitter<AnalyticsState> emit) async {
    final cached = _repository.getCachedStats(event.teacherId);
    if (cached != null && event.startDate == null) {
      emit(AnalyticsLoaded(cached));
    } else {
      emit(AnalyticsLoading());
    }

    try {
      final now = DateTime.now();
      final stats = await _repository.fetchTeacherStats(
        teacherId: event.teacherId,
        startDate: event.startDate ?? now.subtract(const Duration(days: 30)),
        endDate: event.endDate ?? now,
      );
      emit(AnalyticsLoaded(stats));
    } catch (e) {
      if (state is! AnalyticsLoaded) {
        emit(AnalyticsError('Failed to load stats: ${e.toString()}'));
      }
    }
  }
}

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

class LoadStats extends AnalyticsEvent {
  final String teacherId;
  final DateTimeRange range;

  const LoadStats({
    required this.teacherId,
    required this.range,
  });

  @override
  List<Object?> get props => [teacherId, range.start, range.end];
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
  final DateTimeRange range;
  const AnalyticsLoaded(this.stats, this.range);
  @override
  List<Object?> get props => [stats, range.start, range.end];
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
    on<LoadStats>(_onLoadStats);
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
      emit(AnalyticsLoaded(
        stats,
        DateTimeRange(
          start: event.startDate ?? now.subtract(const Duration(days: 30)),
          end: event.endDate ?? now,
        ),
      ));
    } catch (e) {
      if (state is! AnalyticsLoaded) {
        emit(AnalyticsError('Failed to load stats: ${e.toString()}'));
      }
    }
  }

  Future<void> _onLoadStats(LoadStats event, Emitter<AnalyticsState> emit) async {
    emit(AnalyticsLoading());
    try {
      final stats = await _repository.fetchTeacherStats(
        teacherId: event.teacherId,
        startDate: event.range.start,
        endDate: event.range.end,
      );
      emit(AnalyticsLoaded(stats, event.range));
    } catch (e) {
      emit(AnalyticsError('Failed to load stats: ${e.toString()}'));
    }
  }
}

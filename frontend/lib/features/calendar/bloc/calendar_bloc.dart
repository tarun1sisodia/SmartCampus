import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/calendar_session_model.dart';
import '../repositories/calendar_repository.dart';

abstract class CalendarEvent extends Equatable {
  const CalendarEvent();

  @override
  List<Object?> get props => <Object?>[];
}

class LoadMonth extends CalendarEvent {
  const LoadMonth(this.month);

  final DateTime month;

  @override
  List<Object?> get props => <Object?>[month];
}

abstract class CalendarState extends Equatable {
  const CalendarState();

  @override
  List<Object?> get props => <Object?>[];
}

class CalendarInitial extends CalendarState {}

class CalendarLoading extends CalendarState {}

class CalendarLoaded extends CalendarState {
  const CalendarLoaded(this.sessionsByDay);

  final Map<DateTime, List<CalendarSessionModel>> sessionsByDay;

  @override
  List<Object?> get props => <Object?>[sessionsByDay];
}

class CalendarError extends CalendarState {
  const CalendarError(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}

class CalendarBloc extends Bloc<CalendarEvent, CalendarState> {
  CalendarBloc(this._repository) : super(CalendarInitial()) {
    on<LoadMonth>(_onLoadMonth);
  }

  final CalendarRepository _repository;

  Future<void> _onLoadMonth(LoadMonth event, Emitter<CalendarState> emit) async {
    emit(CalendarLoading());
    try {
      final sessions = await _repository.fetchSessionsForMonth(
        event.month.year,
        event.month.month,
      );
      final grouped = <DateTime, List<CalendarSessionModel>>{};
      for (final session in sessions) {
        final day = DateTime(
          session.startTime.year,
          session.startTime.month,
          session.startTime.day,
        );
        grouped.putIfAbsent(day, () => <CalendarSessionModel>[]).add(session);
      }
      emit(CalendarLoaded(grouped));
    } catch (e) {
      emit(CalendarError(e.toString()));
    }
  }
}

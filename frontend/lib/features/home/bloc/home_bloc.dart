import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/session_model.dart';
import '../repositories/home_repository.dart';

// Events
abstract class HomeEvent extends Equatable {
  const HomeEvent();
  @override
  List<Object?> get props => [];
}

class HomeLoadRequested extends HomeEvent {
  const HomeLoadRequested();
}

class LoadTodaySessions extends HomeLoadRequested {
  const LoadTodaySessions();
}

// States
abstract class HomeState extends Equatable {
  const HomeState();
  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}
class HomeLoading extends HomeState {}
class HomeLoaded extends HomeState {
  final List<SessionModel> sessions;
  const HomeLoaded(this.sessions);
  @override
  List<Object?> get props => [sessions];
}
class HomeError extends HomeState {
  final String message;
  const HomeError(this.message);
  @override
  List<Object?> get props => [message];
}

// Bloc
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeRepository _homeRepository;

  HomeBloc(this._homeRepository) : super(HomeInitial()) {
    on<HomeLoadRequested>(_onLoadRequested);
  }

  Future<void> _onLoadRequested(HomeLoadRequested event, Emitter<HomeState> emit) async {
    final cached = _homeRepository.getCachedTodaySessions();
    if (cached != null && cached.isNotEmpty) {
      emit(HomeLoaded(cached));
    } else {
      emit(HomeLoading());
    }

    try {
      final sessions = await _homeRepository.fetchTodaySessions();
      emit(HomeLoaded(sessions));
    } catch (e) {
      if (state is! HomeLoaded) {
        emit(HomeError('Failed to load dashboard: ${e.toString()}'));
      }
    }
  }
}

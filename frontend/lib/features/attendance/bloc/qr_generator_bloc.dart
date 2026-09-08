import 'dart:async';
import 'dart:math' as math;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/attendance_repository.dart';
import 'qr_generator_event.dart';
import 'qr_generator_state.dart';

class QrGeneratorBloc extends Bloc<QrGeneratorEvent, QrGeneratorState> {
  final AttendanceRepository _attendanceRepository;
  Timer? _timer;

  QrGeneratorBloc(this._attendanceRepository) : super(QrGeneratorInitial()) {
    on<StartQrGeneration>(_onStartQrGeneration);
    on<RefreshQrToken>(_onRefreshQrToken);
  }

  Future<void> _onStartQrGeneration(
    StartQrGeneration event,
    Emitter<QrGeneratorState> emit,
  ) async {
    emit(QrGeneratorLoading());
    await _fetchToken(event.sessionId, emit);
  }

  Future<void> _onRefreshQrToken(
    RefreshQrToken event,
    Emitter<QrGeneratorState> emit,
  ) async {
    await _fetchToken(event.sessionId, emit);
  }

  Future<void> _fetchToken(
    String sessionId,
    Emitter<QrGeneratorState> emit,
  ) async {
    try {
      final response = await _attendanceRepository.generateQrToken(sessionId);
      emit(QrGeneratorSuccess(response.token, response.expiresIn));
      
      _timer?.cancel();
      // Setup a timer to fetch a new token a couple of seconds before it expires.
      final refreshIn = math.max(1, response.expiresIn - 2);
      _timer = Timer(Duration(seconds: refreshIn), () {
        if (!isClosed) {
          add(RefreshQrToken(sessionId));
        }
      });
    } catch (e) {
      emit(QrGeneratorFailure(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}

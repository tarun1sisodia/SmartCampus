import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/attendance_repository.dart';
import '../repositories/location_service.dart';
import '../models/qr_verification_request.dart';
import 'qr_scanner_event.dart';
import 'qr_scanner_state.dart';

class QrScannerBloc extends Bloc<QrScannerEvent, QrScannerState> {
  final AttendanceRepository _attendanceRepository;
  final LocationService _locationService;

  QrScannerBloc(this._attendanceRepository, this._locationService) 
    : super(QrScannerInitial()) {
    on<QrCodeScanned>(_onQrCodeScanned);
  }

  Future<void> _onQrCodeScanned(
    QrCodeScanned event,
    Emitter<QrScannerState> emit,
  ) async {
    if (state is QrScannerLoading || state is QrScannerSuccess) return;

    emit(QrScannerLoading());
    try {
      final position = await _locationService.getCurrentLocation();
      
      final request = QrVerificationRequest(
        sessionId: event.sessionId,
        token: event.token,
        lat: position?.latitude,
        lon: position?.longitude,
      );

      await _attendanceRepository.verifyQrToken(request);
      emit(QrScannerSuccess());
    } catch (e) {
      emit(QrScannerFailure(e.toString()));
    }
  }
}

import 'package:equatable/equatable.dart';

abstract class QrScannerEvent extends Equatable {
  const QrScannerEvent();

  @override
  List<Object?> get props => [];
}

class QrCodeScanned extends QrScannerEvent {
  final String sessionId;
  final String token;

  const QrCodeScanned({required this.sessionId, required this.token});

  @override
  List<Object> get props => [sessionId, token];
}

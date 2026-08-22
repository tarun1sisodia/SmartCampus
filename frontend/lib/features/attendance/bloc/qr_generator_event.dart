import 'package:equatable/equatable.dart';

abstract class QrGeneratorEvent extends Equatable {
  const QrGeneratorEvent();

  @override
  List<Object> get props => [];
}

class StartQrGeneration extends QrGeneratorEvent {
  final String sessionId;
  const StartQrGeneration(this.sessionId);

  @override
  List<Object> get props => [sessionId];
}

class RefreshQrToken extends QrGeneratorEvent {
  final String sessionId;
  const RefreshQrToken(this.sessionId);

  @override
  List<Object> get props => [sessionId];
}

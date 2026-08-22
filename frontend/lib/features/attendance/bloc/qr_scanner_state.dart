import 'package:equatable/equatable.dart';

abstract class QrScannerState extends Equatable {
  const QrScannerState();
  
  @override
  List<Object> get props => [];
}

class QrScannerInitial extends QrScannerState {}

class QrScannerLoading extends QrScannerState {}

class QrScannerSuccess extends QrScannerState {}

class QrScannerFailure extends QrScannerState {
  final String message;

  const QrScannerFailure(this.message);

  @override
  List<Object> get props => [message];
}

import 'package:equatable/equatable.dart';

abstract class QrGeneratorState extends Equatable {
  const QrGeneratorState();

  @override
  List<Object> get props => [];
}

class QrGeneratorInitial extends QrGeneratorState {}

class QrGeneratorLoading extends QrGeneratorState {}

class QrGeneratorSuccess extends QrGeneratorState {
  final String token;
  final int expiresIn;

  const QrGeneratorSuccess(this.token, this.expiresIn);

  @override
  List<Object> get props => [token, expiresIn];
}

class QrGeneratorFailure extends QrGeneratorState {
  final String message;

  const QrGeneratorFailure(this.message);

  @override
  List<Object> get props => [message];
}

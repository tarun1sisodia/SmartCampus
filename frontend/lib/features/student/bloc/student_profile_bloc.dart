import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/student_detail_model.dart';
import '../repositories/student_repository.dart';

abstract class StudentProfileEvent extends Equatable {
  const StudentProfileEvent();

  @override
  List<Object?> get props => <Object?>[];
}

class LoadStudentProfile extends StudentProfileEvent {
  const LoadStudentProfile(this.studentId);

  final String studentId;

  @override
  List<Object?> get props => <Object?>[studentId];
}

abstract class StudentProfileState extends Equatable {
  const StudentProfileState();

  @override
  List<Object?> get props => <Object?>[];
}

class StudentProfileInitial extends StudentProfileState {}

class StudentProfileLoading extends StudentProfileState {}

class StudentProfileLoaded extends StudentProfileState {
  const StudentProfileLoaded(this.student, this.summary);

  final StudentDetailModel student;
  final StudentAttendanceSummary summary;

  @override
  List<Object?> get props => <Object?>[student, summary];
}

class StudentProfileError extends StudentProfileState {
  const StudentProfileError(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}

class StudentProfileBloc extends Bloc<StudentProfileEvent, StudentProfileState> {
  StudentProfileBloc(this._repository) : super(StudentProfileInitial()) {
    on<LoadStudentProfile>(_onLoadStudentProfile);
  }

  final StudentRepository _repository;

  Future<void> _onLoadStudentProfile(
    LoadStudentProfile event,
    Emitter<StudentProfileState> emit,
  ) async {
    emit(StudentProfileLoading());
    try {
      final student = await _repository.fetchStudentDetails(event.studentId);
      final summary = await _repository.fetchStudentAttendanceSummary(event.studentId);
      emit(StudentProfileLoaded(student, summary));
    } catch (e) {
      emit(StudentProfileError(e.toString()));
    }
  }
}

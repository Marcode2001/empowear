//lib/bloc/previous_student_work/previous_student_work_bloc.dart
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/previous_student_work_model.dart';
import '../../repositories/previous_student_work_repository.dart';

// ======================================================
// EVENTS
// ======================================================

abstract class PreviousWorkEvent extends Equatable {
  const PreviousWorkEvent();

  @override
  List<Object?> get props => [];
}

class LoadPreviousWorkEvent extends PreviousWorkEvent {
  const LoadPreviousWorkEvent();
}

// ======================================================
// STATES
// ======================================================

abstract class PreviousWorkState extends Equatable {
  const PreviousWorkState();

  @override
  List<Object?> get props => [];
}

class PreviousWorkInitial extends PreviousWorkState {}

class PreviousWorkLoading extends PreviousWorkState {}

class PreviousWorkLoaded extends PreviousWorkState {
  final List<PreviousStudentWork> projects;

  const PreviousWorkLoaded(this.projects);

  @override
  List<Object?> get props => [projects];
}

class PreviousWorkError extends PreviousWorkState {
  final String message;

  const PreviousWorkError(this.message);

  @override
  List<Object?> get props => [message];
}

// ======================================================
// BLOC
// ======================================================

class PreviousWorkBloc
    extends Bloc<PreviousWorkEvent, PreviousWorkState> {

  final PreviousStudentWorkRepository repository;

  PreviousWorkBloc(this.repository)
      : super(PreviousWorkInitial()) {

    on<LoadPreviousWorkEvent>(_onLoadProjects);
  }

  Future<void> _onLoadProjects(
      LoadPreviousWorkEvent event,
      Emitter<PreviousWorkState> emit,
      ) async {

    emit(PreviousWorkLoading());

    try {

      final projects = await repository.loadProjects();

      emit(PreviousWorkLoaded(projects));

    } catch (e) {

      emit(PreviousWorkError(e.toString()));
    }
  }
}
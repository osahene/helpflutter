import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:helpflutter/data/models/dependent.dart';
import 'package:helpflutter/data/models/contact.dart'; // for ContactStatus
import 'package:helpflutter/data/repositories/dependent_repository.dart';

part 'dependent_event.dart';
part 'dependent_state.dart';

class DependentsBloc extends Bloc<DependentsEvent, DependentsState> {
  final DependentRepository repository;

  DependentsBloc({required this.repository}) : super(DependentsInitial()) {
    on<LoadDependents>(_onLoadDependents);
    on<UpdateDependentsStatus>(_onUpdateDependentStatus); // corrected name
  }

  Future<void> _onLoadDependents(
    LoadDependents event,
    Emitter<DependentsState> emit,
  ) async {
    emit(DependentsLoading());
    try {
      final dependents = await repository.getDependents();
      emit(DependentsLoaded(dependents));
    } catch (e) {
      emit(DependentsError(e.toString()));
    }
  }

  Future<void> _onUpdateDependentStatus(
    UpdateDependentsStatus event,
    Emitter<DependentsState> emit,
  ) async {
    try {
      await repository.updateDependentStatus(event.dependentId, event.status);
      add(LoadDependents()); // reload
    } catch (e) {
      emit(DependentsError(e.toString()));
    }
  }
}

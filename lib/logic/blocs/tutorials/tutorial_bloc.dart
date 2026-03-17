import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:helpflutter/data/models/tutorial.dart';
import 'package:helpflutter/data/repositories/tutorial_repository.dart';

part 'tutorial_event.dart';
part 'tutorial_state.dart';

class TutorialsBloc extends Bloc<TutorialEvent, TutorialState> {
  final TutorialRepository repository;

  TutorialsBloc({required this.repository}) : super(TutorialInitial()) {
    on<LoadTutorials>(_onLoadTutorials);
  }

  Future<void> _onLoadTutorials(
    LoadTutorials event,
    Emitter<TutorialState> emit,
  ) async {
    emit(TutorialLoading());
    try {
      final tutorials = await repository.getTutorials();
      emit(TutorialLoaded(tutorials));
    } catch (e) {
      emit(TutorialError(e.toString()));
    }
  }
}

part of 'tutorial_bloc.dart';

abstract class TutorialState extends Equatable {
  const TutorialState();

  @override
  List<Object> get props => [];
}

class TutorialInitial extends TutorialState {}

class TutorialLoading extends TutorialState {}

class TutorialLoaded extends TutorialState {
  final List<Tutorial> tutorials;

  const TutorialLoaded(this.tutorials);

  @override
  List<Object> get props => [tutorials];
}

class TutorialError extends TutorialState {
  final String message;

  const TutorialError(this.message);

  @override
  List<Object> get props => [message];
}

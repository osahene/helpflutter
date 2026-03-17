part of 'tutorial_bloc.dart';

abstract class TutorialEvent extends Equatable {
  const TutorialEvent();

  @override
  List<Object> get props => [];
}

class LoadTutorials extends TutorialEvent {}

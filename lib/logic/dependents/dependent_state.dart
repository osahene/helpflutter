part of 'dependent_bloc.dart';

abstract class DependentsState extends Equatable {
  const DependentsState();

  @override
  List<Object> get props => [];
}

class DependentsInitial extends DependentsState {}

class DependentsLoading extends DependentsState {}

class DependentsLoaded extends DependentsState {
  final List<Dependent> dependents;

  const DependentsLoaded(this.dependents);

  @override
  List<Object> get props => [dependents];
}

class DependentsError extends DependentsState {
  final String message;

  const DependentsError(this.message);

  @override
  List<Object> get props => [message];
}

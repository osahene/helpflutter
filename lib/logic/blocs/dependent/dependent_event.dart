part of 'dependent_bloc.dart';

abstract class DependentsEvent extends Equatable {
  const DependentsEvent();

  @override
  List<Object> get props => [];
}

class LoadDependents extends DependentsEvent {}

class DeleteDependent extends DependentsEvent {
  final String dependentId;

  const DeleteDependent({required this.dependentId});

  @override
  List<Object> get props => [dependentId];
}

class UpdateDependentsStatus extends DependentsEvent {
  final String dependentId;
  final DependentStatus status;

  const UpdateDependentsStatus({
    required this.dependentId,
    required this.status,
  });

  @override
  List<Object> get props => [dependentId, status];
}

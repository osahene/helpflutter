part of 'register_contact_bloc.dart';

abstract class RegisterContactState extends Equatable {
  const RegisterContactState();

  @override
  List<Object> get props => [];
}

class RegisterContactInitial extends RegisterContactState {}

class RegisterContactLoading extends RegisterContactState {}

class RegisterContactSuccess extends RegisterContactState {}

class RegisterContactFailure extends RegisterContactState {
  final String message;

  const RegisterContactFailure(this.message);

  @override
  List<Object> get props => [message];
}

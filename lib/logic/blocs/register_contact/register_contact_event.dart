part of 'register_contact_bloc.dart';

abstract class RegisterContactEvent extends Equatable {
  const RegisterContactEvent();

  @override
  List<Object> get props => [];
}

class SubmitContact extends RegisterContactEvent {
  final String firstName;
  final String lastName;
  final String address;
  final String phone;
  final String email;
  final String relation;
  final List<String> situations;

  const SubmitContact({
    required this.firstName,
    required this.lastName,
    required this.address,
    required this.phone,
    required this.email,
    required this.relation,
    required this.situations,
  });

  @override
  List<Object> get props => [
    firstName,
    lastName,
    address,
    phone,
    email,
    relation,
    situations,
  ];
}

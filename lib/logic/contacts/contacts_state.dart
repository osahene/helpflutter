part of 'contacts_bloc.dart';

abstract class ContactsState extends Equatable {
  const ContactsState();
  @override
  List<Object?> get props => [];
}

class ContactsInitial extends ContactsState {}

class ContactsLoading extends ContactsState {}

class ContactsLoaded extends ContactsState {
  final List<Contact> contacts;
  const ContactsLoaded(this.contacts);
  @override
  List<Object> get props => [contacts];
}

class ContactsError extends ContactsState {
  final String message;
  const ContactsError(this.message);
  @override
  List<Object> get props => [message];
}

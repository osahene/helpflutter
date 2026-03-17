part of 'contacts_bloc.dart';

abstract class ContactsEvent extends Equatable {
  const ContactsEvent();

  @override
  List<Object> get props => [];
}

class LoadContacts extends ContactsEvent {}

class DeleteContact extends ContactsEvent {
  final String contactId;

  const DeleteContact({required this.contactId});

  @override
  List<Object> get props => [contactId];
}

class UpdateContactStatus extends ContactsEvent {
  final String contactId;
  final ContactStatus status;

  const UpdateContactStatus({required this.contactId, required this.status});

  @override
  List<Object> get props => [contactId, status];
}

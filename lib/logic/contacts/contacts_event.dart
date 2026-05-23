part of 'contacts_bloc.dart';

abstract class ContactsEvent extends Equatable {
  const ContactsEvent();
  @override
  List<Object?> get props => [];
}

class LoadContacts extends ContactsEvent {}

class AddContact extends ContactsEvent {
  final String firstName;
  final String lastName;
  final String countryCode;
  final String phoneNumber;
  final String email;
  final String relation;
  final Map<String, dynamic>? situation;
  const AddContact(
    this.firstName,
    this.lastName,
    this.countryCode,
    this.phoneNumber,
    this.email,
    this.relation,
    this.situation,
  );
  @override
  List<Object?> get props => [
    firstName,
    lastName,
    countryCode,
    phoneNumber,
    email,
    relation,
    situation,
  ];
}

class DeleteContact extends ContactsEvent {
  final String contactId;
  const DeleteContact(this.contactId);
  @override
  List<Object> get props => [contactId];
}

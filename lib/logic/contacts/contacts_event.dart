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
  final List<String> situation;

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

/// Carries all editable contact fields so the bloc can forward them to the
/// repository and ultimately to the API.
class UpdateContactInfo extends ContactsEvent {
  final String contactId;
  final String firstName;
  final String lastName;
  final String countryCode;
  final String phoneNumber;
  final String relation;
  final List<String> situation;

  const UpdateContactInfo(
    this.contactId,
    this.firstName,
    this.lastName,
    this.countryCode,
    this.phoneNumber,
    this.relation,
    this.situation,
  );

  @override
  List<Object> get props => [
    contactId,
    firstName,
    lastName,
    countryCode,
    phoneNumber,
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

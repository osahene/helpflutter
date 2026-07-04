import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:helpflutter/data/models/contact.dart';
import 'package:helpflutter/data/repositories/contact_repository.dart';

part 'contacts_event.dart';
part 'contacts_state.dart';

class ContactsBloc extends Bloc<ContactsEvent, ContactsState> {
  final ContactRepository repository;

  ContactsBloc({required this.repository}) : super(ContactsInitial()) {
    on<LoadContacts>(_onLoad);
    on<AddContact>(_onAdd);
    on<UpdateContactInfo>(_onUpdate);
    on<DeleteContact>(_onDelete);
  }

  Future<void> _onLoad(LoadContacts event, Emitter<ContactsState> emit) async {
    emit(ContactsLoading());
    try {
      final contacts = await repository.getContacts();
      emit(ContactsLoaded(contacts));
    } catch (e) {
      emit(ContactsError(e.toString()));
    }
  }

  Future<void> _onAdd(AddContact event, Emitter<ContactsState> emit) async {
    // emit(ContactsLoading());
    try {
      final newContact = Contact(
        id: '',
        firstName: event.firstName,
        lastName: event.lastName,
        countryCode: event.countryCode,
        phoneNumber: event.phoneNumber,
        emailAddress: event.email,
        relation: event.relation,
        situation: event.situation,
        status: ContactStatus.pending,
      );
      await repository.addContact(newContact);
      final contacts = await repository.getContacts();
      emit(ContactsLoaded(contacts));
    } catch (e) {
      emit(ContactsError(e.toString()));
    }
  }

  /// Forwards every editable field to the repository so the full payload
  /// reaches the API — not just the contact ID.
  Future<void> _onUpdate(
    UpdateContactInfo event,
    Emitter<ContactsState> emit,
  ) async {
    // emit(ContactsLoading());
    try {
      await repository.updateContactInfo(
        contactId: event.contactId,
        firstName: event.firstName,
        lastName: event.lastName,
        countryCode: event.countryCode,
        phoneNumber: event.phoneNumber,
        relation: event.relation,
        situation: event.situation,
      );
      final contacts = await repository.getContacts();
      emit(ContactsLoaded(contacts));
    } catch (e) {
      emit(ContactsError(e.toString()));
    }
  }

  Future<void> _onDelete(
    DeleteContact event,
    Emitter<ContactsState> emit,
  ) async {
    // emit(ContactsLoading());
    try {
      await repository.deleteContact(event.contactId);
      final contacts = await repository.getContacts();
      emit(ContactsLoaded(contacts));
    } catch (e) {
      emit(ContactsError(e.toString()));
    }
  }
}

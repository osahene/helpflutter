import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:helpflutter/data/models/contact.dart';
import 'package:helpflutter/data/repositories/contact_repository.dart';

part 'contacts_event.dart';
part 'contacts_state.dart';

class ContactsBloc extends Bloc<ContactsEvent, ContactsState> {
  final ContactRepository repository;

  ContactsBloc({required this.repository}) : super(ContactsInitial()) {
    on<LoadContacts>(_onLoadContacts);
    on<DeleteContact>(_onDeleteContact);
    on<UpdateContactStatus>(_onUpdateContactStatus);
  }

  Future<void> _onLoadContacts(
    LoadContacts event,
    Emitter<ContactsState> emit,
  ) async {
    emit(ContactsLoading());
    try {
      final contacts = await repository.getContacts();
      emit(ContactsLoaded(contacts));
    } catch (e) {
      emit(ContactsError(e.toString()));
    }
  }

  Future<void> _onDeleteContact(
    DeleteContact event,
    Emitter<ContactsState> emit,
  ) async {
    try {
      await repository.deleteContact(event.contactId);
      add(LoadContacts()); // reload
    } catch (e) {
      emit(ContactsError(e.toString()));
    }
  }

  Future<void> _onUpdateContactStatus(
    UpdateContactStatus event,
    Emitter<ContactsState> emit,
  ) async {
    try {
      await repository.updateContactStatus(
        event.contactId,
        event.status.toString(),
      );
      add(LoadContacts());
    } catch (e) {
      emit(ContactsError(e.toString()));
    }
  }
}

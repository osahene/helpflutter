import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:helpflutter/data/models/contact.dart';
import 'package:helpflutter/data/repositories/contact_repository.dart';

part 'register_contact_event.dart';
part 'register_contact_state.dart';

class RegisterContactBloc
    extends Bloc<RegisterContactEvent, RegisterContactState> {
  final ContactRepository repository;

  RegisterContactBloc({required this.repository})
    : super(RegisterContactInitial()) {
    on<SubmitContact>(_onSubmitContact);
  }

  Future<void> _onSubmitContact(
    SubmitContact event,
    Emitter<RegisterContactState> emit,
  ) async {
    emit(RegisterContactLoading());
    try {
      // Normally you'd generate ID on backend
      final contact = Contact(
        id: DateTime.now().toString(),
        firstName: event.firstName,
        lastName: event.lastName,
        address: event.address,
        phone: event.phone,
        email: event.email,
        relation: event.relation,
        situations: event.situations,
        status: ContactStatus.pending, // new contacts are pending
      );
      await repository.addContact(contact);
      emit(RegisterContactSuccess());
    } catch (e) {
      emit(RegisterContactFailure(e.toString()));
    }
  }
}

import 'package:helpflutter/data/models/contact.dart';

abstract class ContactRepository {
  Future<List<Contact>> getContacts();
  Future<void> addContact(Contact contact);
  Future<void> updateContactStatus(String contactId, ContactStatus status);
  Future<void> deleteContact(String contactId);
}

class MockContactRepository implements ContactRepository {
  final List<Contact> _mockContacts = [
    Contact(
      id: '1',
      firstName: 'John',
      lastName: 'Doe',
      address: '123 Main St',
      phone: '+233501234567',
      email: 'john@example.com',
      relation: 'Friend',
      situations: ['Fire', 'Accident'],
      status: ContactStatus.accepted,
    ),
    Contact(
      id: '2',
      firstName: 'Jane',
      lastName: 'Smith',
      address: '456 Oak Ave',
      phone: '+233501234568',
      email: 'jane@example.com',
      relation: 'Sister',
      situations: ['Health'],
      status: ContactStatus.pending,
    ),
  ];

  @override
  Future<List<Contact>> getContacts() async {
    await Future.delayed(const Duration(seconds: 1));
    return _mockContacts;
  }

  @override
  Future<void> addContact(Contact contact) async {
    await Future.delayed(const Duration(seconds: 1));
    _mockContacts.add(contact);
  }

  @override
  Future<void> updateContactStatus(
    String contactId,
    ContactStatus status,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _mockContacts.indexWhere((c) => c.id == contactId);
    if (index != -1) {
      _mockContacts[index] = Contact(
        id: _mockContacts[index].id,
        firstName: _mockContacts[index].firstName,
        lastName: _mockContacts[index].lastName,
        address: _mockContacts[index].address,
        phone: _mockContacts[index].phone,
        email: _mockContacts[index].email,
        relation: _mockContacts[index].relation,
        situations: _mockContacts[index].situations,
        status: status,
      );
    }
  }

  @override
  Future<void> deleteContact(String contactId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _mockContacts.removeWhere((c) => c.id == contactId);
  }
}

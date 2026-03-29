import 'package:helpflutter/data/models/contact.dart';
import 'package:helpflutter/core/api/api_service.dart';
import 'package:dio/dio.dart';

abstract class ContactRepository {
  Future<List<Contact>> getContacts();
  Future<void> addContact(Contact contact);
  Future<void> updateContactStatus(String contactId, String status);
  Future<void> deleteContact(String contactId);
}

class ContactRepositoryImpl implements ContactRepository {
  final ApiService apiService;

  ContactRepositoryImpl({required this.apiService});

  @override
  Future<List<Contact>> getContacts() async {
    try {
      final response = await apiService.getMyContacts();

      // Assuming your Django API returns a list of contact objects
      final List<dynamic> data = response.data;
      return data.map((json) => Contact.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception('Failed to fetch contacts: ${e.message}');
    }
  }

  @override
  Future<void> addContact(Contact contact) async {
    try {
      // Map the Contact model to the JSON structure your Django view expects
      final payload = contact.toJson();
      await apiService.createRelation(payload);
    } on DioException catch (e) {
      throw Exception(
        'Failed to add contact: ${e.response?.data ?? e.message}',
      );
    }
  }

  @override
  Future<void> updateContactStatus(String contactId, String status) async {
    try {
      // Based on your ApiService: updateInviteStatus handles status changes
      final payload = {
        'contact_id': contactId,
        'status': status, // e.g., 'accepted' or 'rejected'
      };
      await apiService.updateInviteStatus(payload);
    } on DioException catch (e) {
      throw Exception('Failed to update status: ${e.message}');
    }
  }

  @override
  Future<void> deleteContact(String contactId) async {
    try {
      // Your ApiService expects a Map for deleteContact
      await apiService.deleteContact({'contact_id': contactId});
    } on DioException catch (e) {
      throw Exception('Failed to delete contact: ${e.message}');
    }
  }
}

import 'package:dio/dio.dart';
import 'package:helpflutter/data/models/contact.dart';
import 'package:helpflutter/core/constants/api_service.dart';

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
  Future<void> addContact(Contact contact) async {
    try {
      // Map the Contact model to the JSON structure your Django view expects
      await apiService.createRelation(contact.toJson());
    } on DioException catch (e) {
      throw Exception(
        'Failed to add contact: ${e.response?.data ?? e.message}',
      );
    }
  }

  @override
  Future<void> deleteContact(String contactId) async {
    try {
      await apiService.deleteContact(contactId);
    } on DioException catch (e) {
      throw Exception(
        'Failed to delete contact: ${e.response?.data ?? e.message}',
      );
    }
  }

  @override
  Future<List<Contact>> getContacts() async {
    try {
      final response = await apiService.getMyContacts();

      if (response.data != null && response.data['data'] is List) {
        final List<dynamic> rawList = response.data['data'];
        return rawList.map((json) => Contact.fromJson(json)).toList();
      }

      return [];
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return [];

      throw Exception('Server Error: ${e.response?.statusCode}');
    }
  }

  @override
  Future<void> updateContactStatus(String contactId, String status) async {
    try {
      final payload = {
        'contact_id': contactId,
        'status': status, // 'approved' or 'rejected'
      };

      if (status == 'approved') {
        await apiService.approveDependant(payload);
      } else if (status == 'rejected') {
        await apiService.rejectDependant(payload);
      }
    } on DioException catch (e) {
      throw Exception(
        'Failed to update contact status: ${e.response?.data ?? e.message}',
      );
    }
  }
}

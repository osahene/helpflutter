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
      final dynamic data = response.data;

      // 1. If the response is a Map and contains a 'data' key
      if (data is Map<String, dynamic> && data['data'] is List) {
        final List<dynamic> rawList = data['data'];
        return rawList.map((json) => Contact.fromJson(json)).toList();
      }

      // 2. If the response is the List itself (common in some Django REST setups)
      if (data is List) {
        return data.map((json) => Contact.fromJson(json)).toList();
      }

      // Default to empty if structure is unknown or null
      return [];
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return [];
      throw Exception('Server Error: ${e.response?.statusCode}');
    } catch (e) {
      // Catch parsing errors and return empty to trigger your UI empty state
      return [];
    }
  }

  @override
  Future<void> updateContactStatus(String contactId, String status) async {
    try {
      final payload = {'contact_id': contactId, 'status': status};

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

import 'package:dio/dio.dart';
import 'package:helpflutter/data/models/contact.dart';
import 'package:helpflutter/core/constants/api_service.dart';

abstract class ContactRepository {
  Future<List<Contact>> getContacts();
  Future<void> addContact(Contact contact);

  /// All editable fields are now required so every change reaches the API.
  Future<void> updateContactInfo({
    required String contactId,
    required String firstName,
    required String lastName,
    required String countryCode,
    required String phoneNumber,
    required String relation,
    required List<String> situation,
  });

  Future<void> deleteContact(String contactId);
}

class ContactRepositoryImpl implements ContactRepository {
  final ApiService apiService;

  ContactRepositoryImpl({required this.apiService});

  @override
  Future<void> addContact(Contact contact) async {
    try {
      final res = await apiService.createRelation(contact.toJson());
      print(res);
    } on DioException catch (e) {
      throw Exception(
        'Failed to add contact: ${e.response?.data ?? e.message}',
      );
    }
  }

  @override
  Future<void> deleteContact(String contactId) async {
    try {
      await apiService.deleteContact({'pk': contactId});
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

      if (data is Map<String, dynamic>) {
        final List<dynamic>? rawList = data['results'] is List
            ? data['results']
            : data['data'] is List
            ? data['data']
            : null;

        if (rawList != null) {
          return rawList.map((json) => Contact.fromJson(json)).toList();
        }
      }

      if (data is List) {
        return data.map((json) => Contact.fromJson(json)).toList();
      }

      return [];
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return [];
      throw Exception('Server Error: ${e.response?.statusCode}');
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> updateContactInfo({
    required String contactId,
    required String firstName,
    required String lastName,
    required String countryCode,
    required String phoneNumber,
    required String relation,
    required List<String> situation,
  }) async {
    try {
      final payload = {
        'contact_id': contactId,
        'first_name': firstName,
        'last_name': lastName,
        'country_code': countryCode,
        'phone_number': phoneNumber,
        'relation': relation,
        'situations': situation,
      };
      await apiService.updateContact(payload);
    } on DioException catch (e) {
      throw Exception(
        'Failed to update contact: ${e.response?.data ?? e.message}',
      );
    }
  }
}

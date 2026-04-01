import 'package:dio/dio.dart';
import 'package:helpflutter/core/constants/constants.dart';
import 'package:helpflutter/core/constants/api_client.dart';
import 'package:helpflutter/data/models/contact.dart';

class ContactsRepository {
  final Dio _dio = ApiClient.dio;

  Future<List<Contact>> getContacts() async {
    try {
      final response = await _dio.get(AppConstants.myContacts);
      final List<dynamic> data = response.data;
      return data.map((json) => Contact.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> createContact({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String email,
    required String relation,
    required List<String> situations, // though backend may not use it in create
  }) async {
    try {
      await _dio.post(
        AppConstants.createContact,
        data: {
          'first_name': firstName,
          'last_name': lastName,
          'phone_number': phoneNumber,
          'email_address': email,
          'relation': relation,
          // 'situations': situations, // uncomment if backend expects
        },
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteContact(String contactId) async {
    try {
      await _dio.post(AppConstants.deleteContact, data: {'pk': contactId});
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException e) {
    if (e.response != null) {
      final data = e.response!.data;
      if (data is Map && data.containsKey('error')) return data['error'];
      if (data is Map && data.containsKey('message')) return data['message'];
    }
    return e.message ?? 'Network error';
  }
}

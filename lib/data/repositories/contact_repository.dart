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

/// A contact action that failed — [message] is plain language, shown to the
/// user as-is (ContactsBloc emits `e.toString()`).
class ContactException implements Exception {
  final String message;
  const ContactException(this.message);

  @override
  String toString() => message;

  factory ContactException.from(DioException e, String action) {
    final data = e.response?.data;
    if (data is Map) {
      final serverMessage = data['error'] ?? data['detail'] ?? data['message'];
      if (serverMessage is String && serverMessage.isNotEmpty) {
        return ContactException(serverMessage);
      }
    }
    switch (e.type) {
      case DioExceptionType.connectionError:
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ContactException(
          "Couldn't $action — check your internet connection and try again.",
        );
      default:
        return ContactException("Couldn't $action. Please try again.");
    }
  }
}

class ContactRepositoryImpl implements ContactRepository {
  final ApiService apiService;

  ContactRepositoryImpl({required this.apiService});

  @override
  Future<void> addContact(Contact contact) async {
    try {
      await apiService.createRelation(contact.toJson());
    } on DioException catch (e) {
      throw ContactException.from(e, 'add this contact');
    }
  }

  @override
  Future<void> deleteContact(String contactId) async {
    try {
      await apiService.deleteContact({'pk': contactId});
    } on DioException catch (e) {
      throw ContactException.from(e, 'delete this contact');
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
      throw ContactException.from(e, 'load your contacts');
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
      throw ContactException.from(e, 'update this contact');
    }
  }
}

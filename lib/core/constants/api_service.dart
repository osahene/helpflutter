import 'package:dio/dio.dart';
import 'package:helpflutter/core/constants/api_client.dart';
import 'package:helpflutter/core/constants/constants.dart';

class ApiService {
  final Dio _dio = ApiClient.instance;

  // Authentication
  Future<Response> login(Map<String, dynamic> data) =>
      _dio.post(AppConstants.login, data: data);

  Future<Response> logout() => _dio.post(AppConstants.logout);

  Future<Response> register(Map<String, dynamic> data) =>
      _dio.post(AppConstants.register, data: data);

  Future<Response> sendOtp(Map<String, dynamic> data) =>
      _dio.post(AppConstants.sendOtp, data: data);

  Future<Response> verifyOtp(Map<String, dynamic> data) =>
      _dio.post(AppConstants.verifyOtp, data: data);

  Future<Response> getUserProfile() =>
      _dio.get('/auth/profile/'); // Adjust path to your API
  Future<Response> getRequestHistory() => _dio.get('/alerts/history/');

  // Contacts & Relations
  Future<Response> getContactInfo(String contactId) =>
      _dio.get('${AppConstants.myContacts}$contactId/');

  Future<Response> updateInviteStatus(Map<String, dynamic> data) =>
      _dio.post(AppConstants.inviteStatus, data: data);

  Future<Response> createRelation(Map<String, dynamic> data) =>
      _dio.post(AppConstants.createContact, data: data);

  Future<Response> getMyContacts() => _dio.get(AppConstants.myContacts);

  Future<Response> getMyDependants() => _dio.get(AppConstants.myDependents);

  Future<Response> approveDependant(Map<String, dynamic> data) =>
      _dio.post(AppConstants.approveDependant, data: data);

  Future<Response> rejectDependant(Map<String, dynamic> data) =>
      _dio.post(AppConstants.rejectDependant, data: data);

  Future<Response> deleteContact(String contactId) =>
      _dio.delete('${AppConstants.deleteContact}$contactId/');

  Future<Response> updateContact(Map<String, dynamic> data) =>
      _dio.post(AppConstants.updateContact, data: data);

  // Alerts
  Future<Response> triggerAlert(Map<String, dynamic> data) =>
      _dio.post(AppConstants.triggerAlert, data: data);

  Future<Response> verifyEmergency(String token) =>
      _dio.get('${AppConstants.verifyEmergency}${Uri.encodeComponent(token)}/');

  Future<Response> decodeEmergencyToken(String token) => _dio.get(
    '${AppConstants.decodeEmergencyToken}${Uri.encodeComponent(token)}/',
  );
}

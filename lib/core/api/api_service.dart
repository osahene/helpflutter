import 'package:dio/dio.dart';
import 'package:helpflutter/core/api/dio_client.dart';
import 'package:helpflutter/core/api/api_constants.dart';

class ApiService {
  final Dio _dio = DioClient.instance;

  // Authentication
  Future<Response> login(Map<String, dynamic> data) =>
      _dio.post(ApiConstants.login, data: data);

  Future<Response> logout() => _dio.post(ApiConstants.logout);

  Future<Response> register(Map<String, dynamic> data) =>
      _dio.post(ApiConstants.register, data: data);

  Future<Response> verifyEmail(Map<String, dynamic> data) =>
      _dio.post(ApiConstants.verifyEmail, data: data);

  Future<Response> verifyPhoneNumber(Map<String, dynamic> data) =>
      _dio.post(ApiConstants.verifyPhoneNumber, data: data);

  Future<Response> verifyPhoneNumberOTP(Map<String, dynamic> data) =>
      _dio.post(ApiConstants.verifyPhoneNumberOTP, data: data);

  Future<Response> forgottenEmail(Map<String, dynamic> data) =>
      _dio.post(ApiConstants.forgottenEmail, data: data);

  Future<Response> confirmPassword(Map<String, dynamic> data) =>
      _dio.post(ApiConstants.confirmPassword, data: data);

  Future<Response> generateRegisterOTP(Map<String, dynamic> data) =>
      _dio.post(ApiConstants.generateRegister, data: data);

  // Contacts & Relations
  Future<Response> getContactInfo(String contactId) =>
      _dio.get('${ApiConstants.contactInfo}$contactId/');

  Future<Response> updateInviteStatus(Map<String, dynamic> data) =>
      _dio.post(ApiConstants.inviteStatus, data: data);

  Future<Response> createRelation(Map<String, dynamic> data) =>
      _dio.post(ApiConstants.createRelation, data: data);

  Future<Response> getMyContacts() => _dio.get(ApiConstants.getMyContacts);

  Future<Response> getMyDependants() => _dio.get(ApiConstants.getMyDependants);

  Future<Response> approveDependant(Map<String, dynamic> data) =>
      _dio.post(ApiConstants.approveDependant, data: data);

  Future<Response> rejectDependant(Map<String, dynamic> data) =>
      _dio.post(ApiConstants.rejectDependant, data: data);

  Future<Response> deleteContact(Map<String, dynamic> data) =>
      _dio.post(ApiConstants.deleteContact, data: data);

  Future<Response> updateContact(Map<String, dynamic> data) =>
      _dio.post(ApiConstants.updateContact, data: data);

  // Alerts
  Future<Response> triggerAlert(Map<String, dynamic> data) =>
      _dio.post(ApiConstants.triggerAlert, data: data);

  Future<Response> verifyEmergency(String token) =>
      _dio.get('${ApiConstants.verifyEmergency}${Uri.encodeComponent(token)}/');

  Future<Response> decodeEmergencyToken(String token) => _dio.get(
    '${ApiConstants.decodeEmergencyToken}${Uri.encodeComponent(token)}/',
  );
}

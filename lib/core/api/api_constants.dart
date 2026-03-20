class ApiConstants {
  // Base URL – can be overridden with environment variables
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://127.0.0.1:8000',
  );

  // API Key for frontend identification
  static const String apiKey = String.fromEnvironment(
    'FRONTEND_API_KEY',
    defaultValue: 'your-api-key-here', // replace with actual key
  );

  // Endpoints
  static const String login = '/account/user-login/';
  static const String logout = '/account/user-logout/';
  static const String refreshToken = '/account/token/refresh/';
  static const String register = '/account/user-register/';
  static const String verifyEmail = '/account/verify-email/';
  static const String verifyPhoneNumber = '/account/verify-phone-number/';
  static const String verifyPhoneNumberOTP =
      '/account/verify-phone-number-otp/';
  static const String forgottenEmail = '/account/request-reset-email/';
  static const String confirmPassword = '/account/password-reset/';
  static const String generateRegister = '/account/user-register-generate-otp/';
  static const String contactInfo = '/account/contacts/'; // + id
  static const String inviteStatus = '/account/update-status/';
  static const String createRelation = '/account/create-relation/';
  static const String getMyContacts = '/account/my-contacts/';
  static const String getMyDependants = '/account/my-dependants/';
  static const String approveDependant = '/account/approve-dependent/';
  static const String rejectDependant = '/account/reject-dependent/';
  static const String deleteContact = '/account/delete-contact/';
  static const String updateContact = '/account/update-contact/';
  static const String triggerAlert = '/account/trigger-alert/';
  static const String verifyEmergency = '/account/verify-alert/'; // + token
  static const String decodeEmergencyToken =
      '/account/decode-alert-token/'; // + token
}

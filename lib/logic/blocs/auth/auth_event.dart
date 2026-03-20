part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class CheckAuthStatus extends AuthEvent {}

class LogoutRequested extends AuthEvent {}

class LoginWithEmailRequested extends AuthEvent {
  final String email;
  final String password;
  final bool remember;
  const LoginWithEmailRequested({
    required this.email,
    required this.password,
    required this.remember,
  });
}

class RegisterWithEmailRequested extends AuthEvent {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  const RegisterWithEmailRequested({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
  });
}

class LoginWithGoogleRequested extends AuthEvent {}

class ForgotPasswordRequested extends AuthEvent {
  final String email;
  const ForgotPasswordRequested(this.email);
}

class ResetPasswordRequested extends AuthEvent {
  final String email;
  final String newPassword;
  const ResetPasswordRequested({
    required this.email,
    required this.newPassword,
  });
}

class SendEmailOtpRequested extends AuthEvent {
  final String email;
  const SendEmailOtpRequested(this.email);
}

class VerifyEmailOtpRequested extends AuthEvent {
  final String email;
  final String otp;
  const VerifyEmailOtpRequested({required this.email, required this.otp});
}

class SendPhoneOtpRequested extends AuthEvent {
  final String countryCode;
  final String phoneNumber;
  const SendPhoneOtpRequested({
    required this.countryCode,
    required this.phoneNumber,
  });
}

class VerifyPhoneOtpRequested extends AuthEvent {
  final String phoneNumber;
  final String otp;
  const VerifyPhoneOtpRequested({required this.phoneNumber, required this.otp});
}

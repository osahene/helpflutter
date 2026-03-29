part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class CheckAuthStatus extends AuthEvent {}

class RegisterWithPhone extends AuthEvent {
  final String firstName;
  final String lastName;
  final String countryCode;
  final String phoneNumber;
  const RegisterWithPhone({
    required this.firstName,
    required this.lastName,
    required this.countryCode,
    required this.phoneNumber,
  });
}

class SendLoginOtp extends AuthEvent {
  final String countryCode;
  final String phoneNumber;
  const SendLoginOtp(this.countryCode, this.phoneNumber);
}

class VerifyOtp extends AuthEvent {
  final String countryCode;
  final String phoneNumber;
  final String otp;
  const VerifyOtp({
    required this.countryCode,
    required this.phoneNumber,
    required this.otp,
  });
}

class LogoutRequested extends AuthEvent {}

part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AuthRegisterRequested extends AuthEvent {
  final String firstName;
  final String lastName;
  final String countryCode;
  final String phoneNumber;
  const AuthRegisterRequested(
    this.firstName,
    this.lastName,
    this.countryCode,
    this.phoneNumber,
  );
  @override
  List<Object> get props => [firstName, lastName, countryCode, phoneNumber];
}

class AuthSendOtpRequested extends AuthEvent {
  final String countryCode;
  final String phoneNumber;
  const AuthSendOtpRequested(this.countryCode, this.phoneNumber);
  @override
  List<Object> get props => [countryCode, phoneNumber];
}

class AuthVerifyOtpRequested extends AuthEvent {
  final String countryCode;
  final String phoneNumber;
  final String otp;
  const AuthVerifyOtpRequested(this.countryCode, this.phoneNumber, this.otp);
  @override
  List<Object> get props => [countryCode, phoneNumber, otp];
}

class AuthLogoutRequested extends AuthEvent {}

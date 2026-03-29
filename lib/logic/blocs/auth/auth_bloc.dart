import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:helpflutter/data/models/user.dart';
import 'package:helpflutter/data/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repository;

  AuthBloc({required this.repository}) : super(AuthInitial()) {
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<RegisterWithPhone>(_onRegisterWithPhone);
    on<SendLoginOtp>(_onSendLoginOtp);
    on<VerifyOtp>(_onVerifyOtp);
    on<LogoutRequested>(_onLogout);
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final isLoggedIn = await repository.isLoggedIn();
    if (isLoggedIn) {
      final user = await repository.getCurrentUser();
      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(Unauthenticated());
      }
    } else {
      emit(Unauthenticated());
    }
  }

  void _onRegisterWithPhone(
    RegisterWithPhone event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await repository.registerWithPhone(
        event.firstName,
        event.lastName,
        event.countryCode,
        event.phoneNumber,
      );
      // After registration, send OTP for login? Actually we can go to login screen directly.
      // We'll just navigate to login screen, not send OTP automatically.
      emit(
        OtpSent(event.countryCode, event.phoneNumber),
      ); // Or maybe we want to go to OTP screen now.
      // But registration doesn't automatically log you in; we send OTP to login later.
      // For simplicity, we'll just emit OtpSent to show OTP screen for registration flow.
      // However, the UI can decide based on context.
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  void _onSendLoginOtp(SendLoginOtp event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await repository.sendLoginOtp(event.countryCode, event.phoneNumber);
      emit(OtpSent(event.countryCode, event.phoneNumber));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  void _onVerifyOtp(VerifyOtp event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await repository.verifyOtp(
        event.countryCode,
        event.phoneNumber,
        event.otp,
      );
      emit(Authenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogout(LogoutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final currentUser = await repository.getCurrentUser();
      if (currentUser?.token != null) {
        await repository.logout();
      }
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}

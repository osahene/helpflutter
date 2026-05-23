import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:helpflutter/core/constants/secure_storage.dart';
import 'package:helpflutter/data/models/user.dart';
import 'package:helpflutter/data/repositories/auth_repository.dart';
import 'package:helpflutter/core/constants/api_client.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repository;

  // 1. ADD THIS VARIABLE
  StreamSubscription? _logoutSubscription;

  AuthBloc({required this.repository}) : super(AuthInitial()) {
    on<AuthRegisterRequested>(_onRegister);
    on<AuthSendOtpRequested>(_onSendOtp);
    on<AuthVerifyOtpRequested>(_onVerifyOtp);
    on<AuthLogoutRequested>(_onLogout);

    _logoutSubscription = ApiClient.logoutStream.listen((_) {
      add(AuthLogoutRequested());
    });
  }

  @override
  Future<void> close() {
    _logoutSubscription?.cancel();
    return super.close();
  }

  Future<void> _onRegister(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await repository.register(
        firstName: event.firstName,
        lastName: event.lastName,
        countryCode: event.countryCode,
        phoneNumber: event.phoneNumber,
      );
      emit(AuthOtpSent());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSendOtp(
    AuthSendOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await repository.sendOtp(
        countryCode: event.countryCode,
        phoneNumber: event.phoneNumber,
      );
      emit(AuthOtpSent());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onVerifyOtp(
    AuthVerifyOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final result = await repository.verifyOtp(
        countryCode: event.countryCode,
        phoneNumber: event.phoneNumber,
        otp: event.otp,
      );
      await SecureStorage.saveAccessToken(result.token);
      await SecureStorage.saveRefreshToken(result.refresh);
      await SecureStorage.setLoggedIn(true);
      emit(AuthAuthenticated(result.user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogout(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    final refreshToken = await SecureStorage.getRefreshToken();
    if (refreshToken != null) {
      await repository.logout(refreshToken).catchError((_) => null);
    }
    await SecureStorage.clearTokens();
    await SecureStorage.setLoggedIn(false);
    emit(AuthUnauthenticated());
  }
}

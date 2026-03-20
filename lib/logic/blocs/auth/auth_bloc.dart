import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:helpflutter/data/models/user.dart';
import 'package:helpflutter/data/repositories/auth_repository.dart';
import 'package:google_sign_in/google_sign_in.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repository;

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  static const List<String> _scopes = [
    'email',
    'https://www.googleapis.com/auth/contacts.readonly',
  ];

  AuthBloc({required this.repository}) : super(AuthInitial()) {
    _googleSignIn.initialize();

    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<LoginWithGoogleRequested>(_onLoginWithGoogle);

    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<LoginWithEmailRequested>(_onLoginWithEmail);
    on<RegisterWithEmailRequested>(_onRegisterWithEmail);
    on<LoginWithGoogleRequested>(_onLoginWithGoogle);
    on<ForgotPasswordRequested>(_onForgotPassword);
    on<ResetPasswordRequested>(_onResetPassword);
    on<SendEmailOtpRequested>(_onSendEmailOtp);
    on<VerifyEmailOtpRequested>(_onVerifyEmailOtp);
    on<SendPhoneOtpRequested>(_onSendPhoneOtp);
    on<VerifyPhoneOtpRequested>(_onVerifyPhoneOtp);
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

  Future<void> _onLoginWithEmail(
    LoginWithEmailRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await repository.loginWithEmail(
        event.email,
        event.password,
        event.remember,
      );
      emit(Authenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onRegisterWithEmail(
    RegisterWithEmailRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await repository.registerWithEmail(
        event.firstName,
        event.lastName,
        event.email,
        event.password,
      );
      emit(Authenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLoginWithGoogle(
    LoginWithGoogleRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      // 1. Trigger the new authentication flow
      // We pass the scopes here as a hint to the system
      final GoogleSignInAccount? googleUser = await _googleSignIn.authenticate(
        scopeHint: _scopes,
      );

      if (googleUser == null) {
        emit(AuthError('Google Sign-In cancelled'));
        return;
      }

      // 2. Get the Identity Token (idToken)
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) throw Exception('No ID token');

      // 3. (Optional) If your backend needs the Access Token for the contacts API:
      // final authClient = await googleUser.authorizationClient.authorizeScopes(_scopes);
      // final accessToken = authClient.accessToken;

      final user = await repository.loginWithGoogle(idToken);
      emit(Authenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onForgotPassword(
    ForgotPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await repository.forgotPassword(event.email);
      emit(PasswordResetSent());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onResetPassword(
    ResetPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await repository.resetPassword(event.email, event.newPassword);
      emit(PasswordResetSuccess());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSendEmailOtp(
    SendEmailOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await repository.sendEmailOtp(event.email);
      emit(EmailOtpSent(event.email));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onVerifyEmailOtp(
    VerifyEmailOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await repository.verifyEmailOtp(event.email, event.otp);
      emit(EmailVerified());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSendPhoneOtp(
    SendPhoneOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await repository.sendPhoneOtp(event.countryCode, event.phoneNumber);
      emit(PhoneOtpSent(event.phoneNumber));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onVerifyPhoneOtp(
    VerifyPhoneOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await repository.verifyPhoneOtp(event.phoneNumber, event.otp);
      emit(PhoneVerified());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogout(LogoutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final currentUser = await repository.getCurrentUser();
      if (currentUser?.token != null) {
        await repository.logout(currentUser!.token!);
      }
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}

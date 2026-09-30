part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final User user;
  const AuthAuthenticated(this.user);
  @override
  List<Object> get props => [user];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
  @override
  List<Object> get props => [message];
}

class AuthOtpSent extends AuthState {}

// Emitted right before AuthUnauthenticated when a deactivate/delete call
// succeeds, purely so a listener can show the server's confirmation
// message before the screen gets swapped out from under it.
class AuthAccountActionSuccess extends AuthState {
  final String message;
  const AuthAccountActionSuccess(this.message);
  @override
  List<Object> get props => [message];
}

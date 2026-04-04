part of 'alert_bloc.dart';

/// States for the alert bloc.
abstract class AlertState extends Equatable {
  const AlertState();

  @override
  List<Object?> get props => [];
}

/// Initial state (no alert in progress).
class AlertInitial extends AlertState {}

/// Alert is being sent.
class AlertSending extends AlertState {}

/// Alert was sent successfully.
class AlertSuccess extends AlertState {
  final String alertId;
  final DateTime timestamp;

  const AlertSuccess({required this.alertId, required this.timestamp});

  @override
  List<Object?> get props => [alertId, timestamp];
}

/// Alert sending failed.
class AlertFailure extends AlertState {
  final String message;

  const AlertFailure(this.message);

  @override
  List<Object?> get props => [message];
}

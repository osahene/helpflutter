part of 'alert_bloc.dart';

abstract class AlertEvent extends Equatable {
  const AlertEvent();

  @override
  List<Object?> get props => [];
}

class SendAlert extends AlertEvent {
  final String situation;
  final bool includeLocation;
  // Same value on every retry of one alert — see AlertRepository.sendAlert.
  final String? clientAlertId;

  const SendAlert({
    required this.situation,
    required this.includeLocation,
    this.clientAlertId,
  });

  @override
  List<Object?> get props => [situation, includeLocation, clientAlertId];
}

/// Event to reset the alert state (e.g., after showing result).
class ResetAlert extends AlertEvent {}

part of 'alert_bloc.dart';

abstract class AlertEvent extends Equatable {
  const AlertEvent();

  @override
  List<Object?> get props => [];
}

class SendAlert extends AlertEvent {
  final String situation;
  final bool includeLocation;

  const SendAlert({required this.situation, required this.includeLocation});

  @override
  List<Object?> get props => [situation, includeLocation];
}

/// Event to reset the alert state (e.g., after showing result).
class ResetAlert extends AlertEvent {}

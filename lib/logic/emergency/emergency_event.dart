part of 'emergency_bloc.dart';

abstract class EmergencyEvent extends Equatable {
  const EmergencyEvent();
  @override
  List<Object?> get props => [];
}

class SendEmergencyAlert extends EmergencyEvent {
  final String alertType;
  final Position location;
  const SendEmergencyAlert(this.alertType, this.location);
  @override
  List<Object> get props => [alertType, location];
}

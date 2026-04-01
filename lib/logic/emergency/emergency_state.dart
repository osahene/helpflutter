part of 'emergency_bloc.dart';

abstract class EmergencyState extends Equatable {
  const EmergencyState();
  @override
  List<Object?> get props => [];
}

class EmergencyInitial extends EmergencyState {}

class EmergencySending extends EmergencyState {}

class EmergencySent extends EmergencyState {}

class EmergencyError extends EmergencyState {
  final String message;
  const EmergencyError(this.message);
  @override
  List<Object> get props => [message];
}

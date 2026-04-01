import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:helpflutter/data/repositories/emergency_repository.dart';

part 'emergency_event.dart';
part 'emergency_state.dart';

class EmergencyBloc extends Bloc<EmergencyEvent, EmergencyState> {
  final EmergencyRepository repository;

  EmergencyBloc(this.repository) : super(EmergencyInitial()) {
    on<SendEmergencyAlert>(_onSend);
  }

  Future<void> _onSend(
    SendEmergencyAlert event,
    Emitter<EmergencyState> emit,
  ) async {
    emit(EmergencySending());
    try {
      await repository.triggerAlert(
        alertType: event.alertType,
        location: event.location,
      );
      emit(EmergencySent());
    } catch (e) {
      emit(EmergencyError(e.toString()));
    }
  }
}

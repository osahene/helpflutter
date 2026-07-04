import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:helpflutter/data/repositories/alert_repository.dart';

part 'alert_event.dart';
part 'alert_state.dart';

/// Bloc responsible for sending emergency alerts.
class AlertBloc extends Bloc<AlertEvent, AlertState> {
  final AlertRepository repository;

  AlertBloc({required this.repository}) : super(AlertInitial()) {
    on<SendAlert>(_onSendAlert);
    on<ResetAlert>(_onResetAlert);
  }
  Future<void> _onSendAlert(SendAlert event, Emitter<AlertState> emit) async {
    emit(AlertSending());
    try {
      final result = await repository.sendAlert(
        situation: event.situation,
        includeLocation: event.includeLocation,
      );
      emit(AlertSuccess(alertId: result.id, timestamp: DateTime.now()));
    } catch (e) {
      print('Failed to send alert: ${e.toString()}');
      emit(AlertFailure(e.toString()));
    }
  }

  void _onResetAlert(ResetAlert event, Emitter<AlertState> emit) {
    emit(AlertInitial());
  }
}

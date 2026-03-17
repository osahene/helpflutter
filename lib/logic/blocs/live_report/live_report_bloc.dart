import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:helpflutter/data/models/live_report.dart';
import 'package:helpflutter/data/repositories/live_report_repository.dart';

part 'live_report_event.dart';
part 'live_report_state.dart';

class LiveReportBloc extends Bloc<LiveReportEvent, LiveReportState> {
  final LiveReportRepository repository;

  LiveReportBloc({required this.repository}) : super(LiveReportInitial()) {
    on<SendTextReport>(_onSendTextReport);
  }

  Future<void> _onSendTextReport(
    SendTextReport event,
    Emitter<LiveReportState> emit,
  ) async {
    emit(LiveReportLoading());
    try {
      final report = LiveReport(
        situation: event.situation,
        recipientIds: event.recipientIds,
        message: event.message,
        type: ReportType.text,
        // location would be added later
      );
      final success = await repository.sendReport(report);
      if (success) {
        emit(LiveReportSuccess());
      } else {
        emit(const LiveReportFailure('Failed to send report'));
      }
    } catch (e) {
      emit(LiveReportFailure(e.toString()));
    }
  }
}

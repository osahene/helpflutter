import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:helpflutter/data/models/live_report.dart';
import 'package:helpflutter/data/repositories/live_report_repository.dart';

part 'live_report_event.dart';
part 'live_report_state.dart';

class LiveReportBloc extends Bloc<LiveReportEvent, LiveReportState> {
  final LiveReportRepository repository;

  LiveReportBloc({required this.repository}) : super(LiveReportInitial()) {
    // Change the event type here to SendLiveReport
    on<SendLiveReport>(_onSendLiveReport);
  }

  Future<void> _onSendLiveReport(
    SendLiveReport event,
    Emitter<LiveReportState> emit,
  ) async {
    emit(LiveReportLoading());
    try {
      final report = LiveReport(
        situation: event.situation,
        recipientIds: event.recipientIds,
        message: event.message,
        type: event.mediaPaths.isEmpty ? ReportType.text : ReportType.video,
        // mediaPaths: event.mediaPaths, // Ensure your LiveReport model has this field!
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

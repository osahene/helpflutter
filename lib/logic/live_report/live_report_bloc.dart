import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:helpflutter/data/models/live_report.dart';
import 'package:helpflutter/data/repositories/live_report_repository.dart';

part 'live_report_event.dart';
part 'live_report_state.dart';

class LiveReportBloc extends Bloc<LiveReportEvent, LiveReportState> {
  final LiveReportRepository repository;

  LiveReportBloc({required this.repository}) : super(LiveReportInitial()) {
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
        agencyIds: event.agencyIds,
        message: event.message,
        media: event.media,
      );

      await repository.sendReport(report);
      emit(LiveReportSuccess());
    } catch (e) {
      emit(LiveReportFailure(e.toString()));
    }
  }
}

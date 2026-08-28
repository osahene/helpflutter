part of 'live_report_bloc.dart';

abstract class LiveReportEvent extends Equatable {
  const LiveReportEvent();

  @override
  List<Object> get props => [];
}

class SendLiveReport extends LiveReportEvent {
  final String situation;
  final String message;
  final List<String> agencyIds;
  final List<LiveReportMedia> media;

  const SendLiveReport({
    required this.situation,
    required this.message,
    required this.agencyIds,
    required this.media,
  });

  @override
  List<Object> get props => [situation, message, agencyIds, media];
}

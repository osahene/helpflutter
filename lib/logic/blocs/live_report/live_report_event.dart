part of 'live_report_bloc.dart';

abstract class LiveReportEvent extends Equatable {
  const LiveReportEvent();

  @override
  List<Object> get props => [];
}

class SendTextReport extends LiveReportEvent {
  final String situation;
  final String message;
  final List<String> recipientIds; // contact IDs or 'police', etc.

  const SendTextReport({
    required this.situation,
    required this.message,
    required this.recipientIds,
  });

  @override
  List<Object> get props => [situation, message, recipientIds];
}

// You can add similar events for audio/video later

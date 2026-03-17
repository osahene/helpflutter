part of 'live_report_bloc.dart';

abstract class LiveReportEvent extends Equatable {
  const LiveReportEvent();

  @override
  List<Object> get props => [];
}

// Rename this from SendTextReport to SendLiveReport
class SendLiveReport extends LiveReportEvent {
  final String situation;
  final String message;
  final List<String> recipientIds;
  final List<String> mediaPaths; // Add this to handle your attachments

  const SendLiveReport({
    required this.situation,
    required this.message,
    required this.recipientIds,
    required this.mediaPaths,
  });

  @override
  List<Object> get props => [situation, message, recipientIds, mediaPaths];
}

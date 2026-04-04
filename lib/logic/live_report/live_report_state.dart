part of 'live_report_bloc.dart';

abstract class LiveReportState extends Equatable {
  const LiveReportState();

  @override
  List<Object> get props => [];
}

class LiveReportInitial extends LiveReportState {}

class LiveReportLoading extends LiveReportState {}

class LiveReportSuccess extends LiveReportState {}

class LiveReportFailure extends LiveReportState {
  final String message;

  const LiveReportFailure(this.message);

  @override
  List<Object> get props => [message];
}

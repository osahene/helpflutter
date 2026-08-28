/// One photo/video/voice-note file attached to a [LiveReport].
class LiveReportMedia {
  final String path;

  /// 'image' | 'video' | 'audio'
  final String type;

  const LiveReportMedia({required this.path, required this.type});
}

class LiveReport {
  final String situation;
  final List<String> agencyIds;
  final String? message;
  final List<LiveReportMedia> media;

  LiveReport({
    required this.situation,
    required this.agencyIds,
    this.message,
    this.media = const [],
  });
}

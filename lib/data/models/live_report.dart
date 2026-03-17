enum ReportType { text, audio, video }

class LiveReport {
  final String situation;
  final List<String> recipientIds; // could be contact IDs or 'police' etc.
  final String? message; // for text reports
  final String? mediaPath; // local path for audio/video
  final ReportType type;
  final double? latitude;
  final double? longitude;

  LiveReport({
    required this.situation,
    required this.recipientIds,
    this.message,
    this.mediaPath,
    required this.type,
    this.latitude,
    this.longitude,
  });

  Map<String, dynamic> toJson() {
    return {
      'situation': situation,
      'recipients': recipientIds,
      'message': message,
      'type': type.toString(),
      'lat': latitude,
      'lng': longitude,
    };
  }
}

class Emergency {
  final String id;
  final String action;
  final DateTime createdAt;
  final Map<String, dynamic> location; // or a dedicated Location class
  final String missionStatus;
  final String smsStatus;
  final String emailStatus;
  final String voiceStatus;

  Emergency({
    required this.id,
    required this.action,
    required this.createdAt,
    required this.location,
    required this.missionStatus,
    required this.smsStatus,
    required this.emailStatus,
    required this.voiceStatus,
  });

  factory Emergency.fromJson(Map<String, dynamic> json) {
    return Emergency(
      id: json['id'],
      action: json['action'],
      createdAt: DateTime.parse(json['created_at']),
      location: json['location'] ?? {},
      missionStatus: json['mission_status'] ?? '',
      smsStatus: json['sms_status'] ?? '',
      emailStatus: json['email_status'] ?? '',
      voiceStatus: json['voice_status'] ?? '',
    );
  }
}

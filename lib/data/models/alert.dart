class Alert {
  final String id;
  final String situation;
  final DateTime timestamp;
  final bool includeLocation;
  final String? customMessage;
  final List<String>
  notifiedContactIds; // IDs of contacts who received the alert

  Alert({
    required this.id,
    required this.situation,
    required this.timestamp,
    required this.includeLocation,
    this.customMessage,
    required this.notifiedContactIds,
  });

  factory Alert.fromJson(Map<String, dynamic> json) {
    return Alert(
      id: json['id'],
      situation: json['situation'],
      timestamp: DateTime.parse(json['timestamp']),
      includeLocation: json['includeLocation'],
      customMessage: json['customMessage'],
      notifiedContactIds: List<String>.from(json['notifiedContactIds']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'situation': situation,
      'timestamp': timestamp.toIso8601String(),
      'includeLocation': includeLocation,
      'customMessage': customMessage,
      'notifiedContactIds': notifiedContactIds,
    };
  }
}

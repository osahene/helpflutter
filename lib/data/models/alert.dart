class Alert {
  final String id;
  final String situation;
  final DateTime timestamp;
  final bool includeLocation;
  final String? customMessage;
  final List<String> notifiedContactIds;

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
      // Fallback to empty string if id is somehow missing
      id: json['id'] ?? '',
      situation: json['situation'] ?? json['alertType'] ?? 'Emergency',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      includeLocation:
          json['includeLocation'] ?? json['include_location'] ?? false,
      customMessage: json['customMessage'] ?? json['message'],
      notifiedContactIds: json['notifiedContactIds'] != null
          ? List<String>.from(json['notifiedContactIds'])
          : [],
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

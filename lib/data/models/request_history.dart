class RequestHistory {
  final String id;
  final String situation;
  final DateTime timestamp;
  final List<String> notifiedContacts; // names or IDs
  final String status; // 'sent', 'failed', etc.

  RequestHistory({
    required this.id,
    required this.situation,
    required this.timestamp,
    required this.notifiedContacts,
    required this.status,
  });

  factory RequestHistory.fromJson(Map<String, dynamic> json) {
    return RequestHistory(
      id: json['id'],
      situation: json['situation'],
      timestamp: DateTime.parse(json['timestamp']),
      notifiedContacts: List<String>.from(json['notified_contacts']),
      status: json['status'],
    );
  }
}

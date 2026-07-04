class RequestHistory {
  final String id;
  final String situation;
  final DateTime timestamp;
  final List<String> notifiedContacts;
  final String status;

  RequestHistory({
    required this.id,
    required this.situation,
    required this.timestamp,
    required this.notifiedContacts,
    required this.status,
  });

  factory RequestHistory.fromJson(Map<String, dynamic> json) {
    // 1. Capture the backend value directly (matches AppConstants.situations)
    final String situation = json['action'] ?? 'Call Emergency';

    // 2. Extract string names out of the backend's recipients list objects
    final List<dynamic> recipientsList = json['recipients'] ?? [];
    final List<String> contacts = recipientsList
        .map((r) => r['contact_name']?.toString() ?? '')
        .where((name) => name.isNotEmpty)
        .toList();

    // 3. Translate backend 'mission_status' into the 'Sent' string the UI expects
    final String missionStatus = json['mission_status'] ?? '';
    final String status = missionStatus == 'success' ? 'Sent' : 'Failed';

    return RequestHistory(
      id: json['id'] ?? '',
      situation: situation,
      timestamp: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      notifiedContacts: contacts,
      status: status,
    );
  }
}

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

  static const Map<String, String> _situationForCode = {
    'fire': 'Fire Outbreak',
    'health': 'Health Crisis',
    'robbery': 'Robbery Attack',
    'violence': 'Violence Alert',
    'flood': 'Flood Alert',
    'other': 'Call Emergency',
  };

  factory RequestHistory.fromJson(Map<String, dynamic> json) {
    // 1. The backend sends the canonical alert code (Emergency.ALERT_TYPES,
    //    e.g. "fire") — map it to the AppConstants.situations label the
    //    history card's colors/icons are keyed by. A value that's already a
    //    label passes through unchanged.
    final String action = json['action']?.toString() ?? '';
    final String situation =
        _situationForCode[action.toLowerCase()] ??
        (action.isEmpty ? 'Call Emergency' : action);

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

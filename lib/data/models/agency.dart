class Agency {
  final String id;
  final String name;
  final String service;
  final String phone;

  Agency({
    required this.id,
    required this.name,
    required this.service,
    required this.phone,
  });

  factory Agency.fromJson(Map<String, dynamic> json) {
    return Agency(
      id: json['id'] as String,
      name: json['name'] as String,
      service: json['service'] as String,
      phone: json['phone'] as String? ?? '',
    );
  }

  /// A simple emoji marker per agency service type, matching the icons
  /// previously hardcoded alongside the national emergency numbers.
  String get icon {
    switch (service) {
      case 'police':
        return '👮';
      case 'fire':
        return '🔥';
      case 'ambulance':
        return '🚑';
      case 'ecg':
        return '⚡';
      default:
        return '🏢';
    }
  }
}

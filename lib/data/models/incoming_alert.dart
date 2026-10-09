/// The reporter of an emergency alert — the person who triggered it, as
/// shown to an emergency contact who is also a registered app user.
class AlertReporter {
  final String name;
  final String phone;

  AlertReporter({required this.name, required this.phone});

  factory AlertReporter.fromJson(Map<String, dynamic> json) {
    return AlertReporter(
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
    );
  }
}

/// A GPS fix for the reporter's device at the time the alert was triggered.
/// May be absent entirely (see [IncomingAlert.location]) if the reporter's
/// device never got a fix.
class AlertLocation {
  final double latitude;
  final double longitude;

  AlertLocation({required this.latitude, required this.longitude});

  factory AlertLocation.fromJson(Map<String, dynamic> json) {
    return AlertLocation(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }
}

/// Detail of an incoming emergency alert, as seen by one of the reporter's
/// approved emergency contacts (fetched via
/// `GET /account/incoming-alert/<emergency_id>/` after a push notification
/// carrying `type: incoming_alert` is received).
class IncomingAlert {
  final String emergencyId;
  final AlertReporter reporter;

  /// The backend alert-type code, e.g. 'fire', 'health', 'robbery',
  /// 'violence', 'flood', 'other'.
  final String situation;

  /// Human-readable label for [situation], e.g. 'Fire outbreak'.
  final String situationDisplay;

  /// Null if the reporter's device never got a GPS fix.
  final AlertLocation? location;

  /// Always present — may be a placeholder raw-coordinate string if reverse
  /// geocoding hasn't completed yet on the backend.
  final String locationDisplay;

  /// Short code used to verify/acknowledge this alert via
  /// `GET /account/verify-emergency/<code>/`.
  final String alertCode;
  final bool isVerified;
  final DateTime createdAt;

  /// The viewer's own contact entry on this alert (how the reporter saved
  /// them) — used to word [message] like the SMS they were sent. Null when
  /// talking to an older backend that doesn't send it.
  final String? contactFirstName;
  final String? contactLastName;
  final String? relation;

  /// Google Maps link to [location], as in the SMS.
  final String? mapsLink;

  /// Link to verify/acknowledge the alert, as in the SMS.
  final String? verificationLink;

  IncomingAlert({
    required this.emergencyId,
    required this.reporter,
    required this.situation,
    required this.situationDisplay,
    required this.location,
    required this.locationDisplay,
    required this.alertCode,
    required this.isVerified,
    required this.createdAt,
    this.contactFirstName,
    this.contactLastName,
    this.relation,
    this.mapsLink,
    this.verificationLink,
  });

  /// The alert worded the same way as the SMS the viewer received
  /// (backend account/messaging.py emergency_sms). The links are left out:
  /// the screen shows the location as a map and the verify link as a button.
  String get message {
    final name = [contactFirstName, contactLastName]
        .where((p) => p != null && p.trim().isNotEmpty)
        .join(' ');
    final who = (relation != null && relation!.trim().isNotEmpty)
        ? 'Your ${relation!.toLowerCase()}, ${reporter.name},'
        : reporter.name;
    return '$situationDisplay Alert,\n\n'
        'Hello${name.isEmpty ? '' : ' $name'},\n\n'
        '$who has triggered an emergency ${situationDisplay.toLowerCase()} '
        'alert. They are at $locationDisplay.\n\n'
        'You are entreated to involve the appropriate agencies in order not '
        'to endanger your life or that of your loved one.';
  }

  factory IncomingAlert.fromJson(Map<String, dynamic> json) {
    final rawLocation = json['location'] as Map<String, dynamic>?;
    return IncomingAlert(
      emergencyId: json['emergency_id'] as String? ?? '',
      reporter: AlertReporter.fromJson(
        json['reporter'] as Map<String, dynamic>? ?? const {},
      ),
      situation: json['situation'] as String? ?? 'other',
      situationDisplay: json['situation_display'] as String? ?? 'Emergency',
      location: rawLocation != null
          ? AlertLocation.fromJson(rawLocation)
          : null,
      locationDisplay:
          json['location_display'] as String? ?? 'Location unavailable',
      alertCode: json['alert_code'] as String? ?? '',
      isVerified: json['is_verified'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      contactFirstName: (json['contact'] as Map?)?['first_name'] as String?,
      contactLastName: (json['contact'] as Map?)?['last_name'] as String?,
      relation: (json['contact'] as Map?)?['relation'] as String?,
      mapsLink: json['maps_link'] as String?,
      verificationLink: json['verification_link'] as String?,
    );
  }
}

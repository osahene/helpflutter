/// A single item in the user's Titbit inbox — weather tips, hazard warnings,
/// seasonal advisories, admin campaigns and system notices.
///
/// Named `Titbit` (not `Notification`) to avoid colliding with Flutter SDK's
/// own `Notification` class.
class Titbit {
  final String id;

  /// One of: weather, hazard, seasonal, general, system.
  final String category;
  final String title;
  final String body;
  final String? icon;

  /// Absolute image URL, or null if this Titbit has no image.
  final String? image;
  final String? source;
  final String? relatedEmergencyId;
  final DateTime createdAt;
  final DateTime? readAt;

  Titbit({
    required this.id,
    required this.category,
    required this.title,
    required this.body,
    this.icon,
    this.image,
    this.source,
    this.relatedEmergencyId,
    required this.createdAt,
    this.readAt,
  });

  bool get isUnread => readAt == null;

  factory Titbit.fromJson(Map<String, dynamic> json) {
    return Titbit(
      id: json['id'] as String,
      category: json['category'] as String? ?? 'general',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      icon: json['icon'] as String?,
      image: json['image'] as String?,
      source: json['source'] as String?,
      relatedEmergencyId: json['related_emergency_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      readAt: json['read_at'] != null
          ? DateTime.parse(json['read_at'] as String)
          : null,
    );
  }

  /// Returns a copy of this Titbit, optionally marked read.
  Titbit copyWith({DateTime? readAt}) {
    return Titbit(
      id: id,
      category: category,
      title: title,
      body: body,
      icon: icon,
      image: image,
      source: source,
      relatedEmergencyId: relatedEmergencyId,
      createdAt: createdAt,
      readAt: readAt ?? this.readAt,
    );
  }
}

/// One paginated page of Titbits, mirroring DRF's PageNumberPagination shape.
class TitbitPage {
  final int count;
  final String? next;
  final String? previous;
  final List<Titbit> results;

  TitbitPage({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory TitbitPage.fromJson(Map<String, dynamic> json) {
    return TitbitPage(
      count: json['count'] as int? ?? 0,
      next: json['next'] as String?,
      previous: json['previous'] as String?,
      results: (json['results'] as List<dynamic>? ?? [])
          .map((e) => Titbit.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class Tutorial {
  final String id;
  final String title;
  final String category;
  final String thumbnailUrl;
  final String videoUrl;
  final Duration? duration;

  Tutorial({
    required this.id,
    required this.title,
    required this.category,
    required this.thumbnailUrl,
    required this.videoUrl,
    this.duration,
  });

  factory Tutorial.fromJson(Map<String, dynamic> json) {
    return Tutorial(
      id: json['id'],
      title: json['title'],
      category: json['category'],
      thumbnailUrl: json['thumbnail_url'],
      videoUrl: json['video_url'],
      // 3. Parse duration from JSON (assuming it's stored as seconds/int)
      duration: json['duration_seconds'] != null
          ? Duration(seconds: json['duration_seconds'])
          : null,
    );
  }
}

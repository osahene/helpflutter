class Tutorial {
  final String id;
  final String title;
  final String category;
  final String videoUrl;
  final Duration? duration;

  Tutorial({
    required this.id,
    required this.title,
    required this.category,
    required this.videoUrl,
    this.duration,
  });

  factory Tutorial.fromJson(Map<String, dynamic> json) {
    return Tutorial(
      id: json['id'],
      title: json['title'],
      category: json['category'],
      videoUrl: json['video_url'],
      // 3. Parse duration from JSON (assuming it's stored as seconds/int)
      duration: json['duration_seconds'] != null
          ? Duration(seconds: json['duration_seconds'])
          : null,
    );
  }

  /// The YouTube video ID parsed out of [videoUrl] (works for both
  /// youtube.com/watch?v= and youtu.be/ links), or null if it can't be parsed.
  String? get youtubeVideoId {
    final uri = Uri.tryParse(videoUrl);
    if (uri == null) return null;
    if (uri.host.contains('youtu.be')) {
      return uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
    }
    return uri.queryParameters['v'];
  }

  /// Thumbnail pulled directly from YouTube for [videoUrl] instead of a
  /// bundled asset, so no per-tutorial thumbnail image ships with the app.
  String? get thumbnailUrl {
    final videoId = youtubeVideoId;
    return videoId != null
        ? 'https://img.youtube.com/vi/$videoId/hqdefault.jpg'
        : null;
  }
}

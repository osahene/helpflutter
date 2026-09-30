class Tutorial {
  final String id;
  final String title;
  final String category;
  // Backend-resolved: either an uploaded video file's URL or an external
  // link (e.g. YouTube) — main_admin.models.Tutorial.video_source picks
  // whichever the admin actually set, so this app never has to know which.
  final String videoUrl;
  final String? thumbnail;
  final Duration? duration;

  Tutorial({
    required this.id,
    required this.title,
    required this.category,
    required this.videoUrl,
    this.thumbnail,
    this.duration,
  });

  factory Tutorial.fromJson(Map<String, dynamic> json) {
    return Tutorial(
      id: json['id'],
      title: json['title'],
      category: json['category'],
      videoUrl: json['video_source'] ?? '',
      thumbnail: json['thumbnail'] as String?,
      duration: json['duration_seconds'] != null
          ? Duration(seconds: json['duration_seconds'])
          : null,
    );
  }

  /// True if [videoUrl] is a YouTube link rather than a directly-hosted
  /// video file — decides which player VideoPlayerScreen uses.
  bool get isYoutube {
    final uri = Uri.tryParse(videoUrl);
    if (uri == null) return false;
    return uri.host.contains('youtube.com') || uri.host.contains('youtu.be');
  }

  /// The YouTube video ID parsed out of [videoUrl] (works for both
  /// youtube.com/watch?v= and youtu.be/ links), or null if it isn't one.
  String? get youtubeVideoId {
    if (!isYoutube) return null;
    final uri = Uri.parse(videoUrl);
    if (uri.host.contains('youtu.be')) {
      return uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
    }
    return uri.queryParameters['v'];
  }

  /// The admin-uploaded thumbnail if there is one; otherwise, for a YouTube
  /// tutorial, YouTube's own thumbnail CDN — so a directly-hosted video
  /// without an uploaded thumbnail is the only case with no image at all.
  String? get thumbnailUrl {
    if (thumbnail != null && thumbnail!.isNotEmpty) return thumbnail;
    final videoId = youtubeVideoId;
    return videoId != null
        ? 'https://img.youtube.com/vi/$videoId/hqdefault.jpg'
        : null;
  }
}

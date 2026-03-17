class Tutorial {
  final String id;
  final String title;
  final String category; // health, flood, fire, robbery, accident
  final String thumbnailUrl;
  final String videoUrl; // could be YouTube link or direct mp4

  Tutorial({
    required this.id,
    required this.title,
    required this.category,
    required this.thumbnailUrl,
    required this.videoUrl,
  });

  factory Tutorial.fromJson(Map<String, dynamic> json) {
    return Tutorial(
      id: json['id'],
      title: json['title'],
      category: json['category'],
      thumbnailUrl: json['thumbnail_url'],
      videoUrl: json['video_url'],
    );
  }

  get duration => null;
}

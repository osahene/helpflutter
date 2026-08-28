import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;
  final String title;

  const VideoPlayerScreen({
    super.key,
    required this.videoUrl,
    required this.title,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late YoutubePlayerController _youtubeController;
  bool _isValidUrl = true;

  @override
  void initState() {
    super.initState();

    // 1. FIX: convertUrlToId is now a static method on YoutubePlayerController
    final videoId = YoutubePlayerController.convertUrlToId(widget.videoUrl);

    if (videoId != null) {
      // 2. FIX: Initialize using the new factory constructor and YoutubePlayerParams
      _youtubeController = YoutubePlayerController.fromVideoId(
        videoId: videoId,
        autoPlay: true,
        params: const YoutubePlayerParams(
          showControls: true,
          showFullscreenButton: true,
          mute: false,
        ),
      );
    } else {
      _isValidUrl = false;
    }
  }

  @override
  void dispose() {
    // 3. FIX: The controller is now freed using .close() instead of .dispose()
    if (_isValidUrl) {
      _youtubeController.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isValidUrl) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: const Center(child: Text('Invalid YouTube URL provided.')),
      );
    }

    // 4. FIX: YoutubePlayerBuilder is gone! The new player natively handles
    // resizing, rotation, and fullscreen overlays automatically.
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: YoutubePlayer(
          controller: _youtubeController,
          aspectRatio: 16 / 9,
        ),
      ),
    );
  }
}

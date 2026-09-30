import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

/// Plays either a directly-hosted video file (an admin-uploaded Tutorial,
/// via video_player) or a YouTube link — [isYoutube] picks the branch so
/// this screen never has to re-derive it; see Tutorial.isYoutube, the same
/// logic that already decided which one this video is.
class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;
  final String title;
  final bool isYoutube;

  const VideoPlayerScreen({
    super.key,
    required this.videoUrl,
    required this.title,
    this.isYoutube = true,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  YoutubePlayerController? _youtubeController;
  VideoPlayerController? _fileController;
  bool _isValidUrl = true;

  @override
  void initState() {
    super.initState();

    if (widget.isYoutube) {
      final videoId = YoutubePlayerController.convertUrlToId(widget.videoUrl);
      if (videoId != null) {
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
    } else {
      if (widget.videoUrl.isEmpty) {
        _isValidUrl = false;
      } else {
        _fileController =
            VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
              ..initialize().then((_) {
                if (mounted) setState(() {});
                _fileController?.play();
              }).catchError((_) {
                if (mounted) setState(() => _isValidUrl = false);
              });
      }
    }
  }

  @override
  void dispose() {
    _youtubeController?.close();
    _fileController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isValidUrl) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: Center(
          child: Text(
            widget.isYoutube
                ? 'Invalid YouTube URL provided.'
                : 'Could not load this video.',
          ),
        ),
      );
    }

    if (widget.isYoutube) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        backgroundColor: Colors.black,
        body: Center(
          child: YoutubePlayer(
            controller: _youtubeController!,
            aspectRatio: 16 / 9,
          ),
        ),
      );
    }

    final controller = _fileController;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: controller != null && controller.value.isInitialized
            ? AspectRatio(
                aspectRatio: controller.value.aspectRatio,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    VideoPlayer(controller),
                    VideoProgressIndicator(controller, allowScrubbing: true),
                  ],
                ),
              )
            : const CircularProgressIndicator(color: Colors.white),
      ),
      floatingActionButton: controller != null && controller.value.isInitialized
          ? FloatingActionButton(
              backgroundColor: Colors.white,
              onPressed: () => setState(() {
                controller.value.isPlaying ? controller.pause() : controller.play();
              }),
              child: Icon(
                controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.black,
              ),
            )
          : null,
    );
  }
}

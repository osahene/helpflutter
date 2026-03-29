import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;
  final String title;
  final String thumbnailUrl;

  const VideoPlayerScreen({
    super.key,
    required this.videoUrl,
    required this.title,
    required this.thumbnailUrl,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _videoController;
  late ChewieController _chewieController;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _videoController = VideoPlayerController.networkUrl(
      Uri.parse(widget.videoUrl),
    );
    _chewieController = ChewieController(
      videoPlayerController: _videoController,
      aspectRatio: 16 / 9,
      autoPlay: true,
      looping: false,
      placeholder: Container(
        color: Colors.black,
        child: Center(
          child: Image.network(
            widget.thumbnailUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.broken_image, color: Colors.white),
          ),
        ),
      ),
      errorBuilder: (context, errorMessage) {
        return Center(
          child: Text(
            'Error loading video',
            style: const TextStyle(color: Colors.white),
          ),
        );
      },
    );
    _videoController.initialize().then((_) {
      setState(() => _isInitialized = true);
    });
  }

  @override
  void dispose() {
    _videoController.dispose();
    _chewieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: _isInitialized
          ? Center(child: Chewie(controller: _chewieController))
          : const Center(child: CircularProgressIndicator()),
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoPath;
  const VideoPlayerScreen({Key? key, required this.videoPath}) : super(key: key);

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(
      // ignore: prefer_const_constructors
      File(widget.videoPath),
    )
      ..initialize().then((_) {
        setState(() {
          _initialized = true;
        });
      });
    _controller.addListener(() {
      setState(() {
        _isPlaying = _controller.value.isPlaying;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlay() {
    if (_controller.value.isPlaying) {
      _controller.pause();
    } else {
      _controller.play();
    }
  }

  void _seekRelative(Duration offset) {
    final newPosition = _controller.value.position + offset;
    _controller.seekTo(newPosition);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Video Player', style: TextStyle(color: Colors.white)),
      ),
      body: Center(
        child: _initialized
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.replay_10, color: Colors.white, size: 32),
                        onPressed: () => _seekRelative(const Duration(seconds: -10)),
                      ),
                      IconButton(
                        icon: Icon(_isPlaying ? Icons.pause_circle : Icons.play_circle, color: Colors.white, size: 48),
                        onPressed: _togglePlay,
                      ),
                      IconButton(
                        icon: const Icon(Icons.forward_10, color: Colors.white, size: 32),
                        onPressed: () => _seekRelative(const Duration(seconds: 10)),
                      ),
                    ],
                  ),
                  VideoProgressIndicator(_controller, allowScrubbing: true, colors: VideoProgressColors(playedColor: Colors.purpleAccent)),
                ],
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
} 
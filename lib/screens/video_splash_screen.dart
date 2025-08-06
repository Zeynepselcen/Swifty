import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'onboarding_screen.dart';

class VideoSplashScreen extends StatefulWidget {
  const VideoSplashScreen({super.key});

  @override
  State<VideoSplashScreen> createState() => _VideoSplashScreenState();
}

class _VideoSplashScreenState extends State<VideoSplashScreen> {
  VideoPlayerController? _videoPlayerController;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      _videoPlayerController = VideoPlayerController.asset('assets/splash_video.mp4');
      await _videoPlayerController!.initialize();
      
      if (mounted) {
        setState(() {
          _isVideoInitialized = true;
        });
        
        // Video'yu oynat
        await _videoPlayerController!.play();
        
        // Video bittiğinde ana ekrana geç
        _videoPlayerController!.addListener(() {
          if (_videoPlayerController!.value.position >= _videoPlayerController!.value.duration) {
            _navigateToNextScreen();
          }
        });
      }
    } catch (e) {
      print('Video yükleme hatası: $e');
      // Video yüklenemezse 3 saniye sonra geç
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          _navigateToNextScreen();
        }
      });
    }
  }

  void _navigateToNextScreen() {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
      );
    }
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A183D),
      body: Center(
        child: _isVideoInitialized && _videoPlayerController != null
            ? AspectRatio(
                aspectRatio: _videoPlayerController!.value.aspectRatio,
                child: VideoPlayer(_videoPlayerController!),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/logom.png', width: 120, height: 120),
                  const SizedBox(height: 20),
                  const Text(
                    'Swifty',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Text(
                    'Galeri Temizleyici',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ],
              ),
      ),
    );
  }
} 
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoBackground extends StatefulWidget {
  const VideoBackground({Key? key}) : super(key: key);

  @override
  _VideoBackgroundState createState() => _VideoBackgroundState();
}

class _VideoBackgroundState extends State<VideoBackground> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    // Initialize the video controller
    _controller = VideoPlayerController.asset('assets/video_background.mp4')
      ..initialize().then((_) {
        setState(() {}); // Ensure the video is ready
        _controller.play(); // Auto-play video
        _controller.setLooping(true); // Loop the video
        _controller.setVolume(0.0); // Mute the video
      });
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Video Background
        SizedBox.expand(
          child:
              _controller.value.isInitialized
                  ? FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _controller.value.size?.width ?? 0,
                      height: _controller.value.size?.height ?? 0,
                      child: VideoPlayer(_controller),
                    ),
                  )
                  : Container(), // Empty container if video isn't ready
        ),

        // Semi-Transparent Overlay
        Positioned.fill(
          child: Container(
            color: Colors.black.withOpacity(0.3), // Adjust opacity as needed
          ),
        ),
      ],
    );
  }
}

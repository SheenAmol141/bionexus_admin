import 'package:video_player/video_player.dart'; //add to dependencies video_player:^2.8.3
import 'package:flutter/material.dart';

class FittedVideo extends StatefulWidget {
  const FittedVideo({super.key});

  @override
  State<FittedVideo> createState() => _FittedVideoState();
}

class _FittedVideoState extends State<FittedVideo> {
  late VideoPlayerController controller;
  
  @override
  void initState() {
    super.initState();
    controller = VideoPlayerController.asset("assets/start_bgcomp.mp4")
      ..initialize().then((value) {
        controller.setLooping(true);
        controller.setVolume(0);
        controller.play();
      });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: 1920,
            height: 1080,
            child: VideoPlayer(controller),
          ),
        ),
      ),
    );
  }
}
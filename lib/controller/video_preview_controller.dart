import 'package:video_player/video_player.dart';

class VideoPreviewController {
  final VideoPlayerController controller;
  final String url;

  VideoPreviewController({required this.url})
      // ignore: deprecated_member_use
      : controller = VideoPlayerController.network(url);

  Future<void> initialize() async {
    await controller.initialize();
    controller.setLooping(true);
  }

  void dispose() {
    controller.dispose();
  }
}

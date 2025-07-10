import 'package:flutter/material.dart';
import 'package:spanky/constrain.dart';
import 'package:spanky/controller/video_upload_controller.dart';
import 'package:spanky/view/screens/widgets/text_input.dart';
import 'dart:io';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

class AddCaptionScreen extends StatefulWidget {
  final File videoFile;
  final String videoPath;

  const AddCaptionScreen({
    super.key,
    required this.videoFile,
    required this.videoPath,
  });

  @override
  State<AddCaptionScreen> createState() => _AddCaptionScreenState();
}

class _AddCaptionScreenState extends State<AddCaptionScreen> {
  late final VideoPlayerController videoPlayerController;
  final VideoUploadController videoUploadController = Get.put(
    VideoUploadController(),
  );

  final TextEditingController songNameController = TextEditingController();
  final TextEditingController captionController = TextEditingController();

  bool isUploading = false;

  @override
  void initState() {
    super.initState();
    videoPlayerController = VideoPlayerController.file(widget.videoFile)
      ..initialize().then((_) {
        setState(() {}); // Trigger UI rebuild
        videoPlayerController
          ..setLooping(true)
          ..setVolume(0.7)
          ..play();
      });
  }

  @override
  void dispose() {
    videoPlayerController.pause();
    videoPlayerController.dispose();
    songNameController.dispose();
    captionController.dispose();
    super.dispose();
  }

  Future<void> _handleUpload() async {
    if (songNameController.text.trim().isEmpty ||
        captionController.text.trim().isEmpty) {
      Get.snackbar(
        "Missing Info",
        "Please provide both a song name and caption.",
      );
      return;
    }

    setState(() => isUploading = true);

    try {
      // pause only if initialized
      if (videoPlayerController.value.isInitialized) {
        videoPlayerController.pause();
      }

      await videoUploadController.uploadVideo(
        songNameController.text.trim(),
        captionController.text.trim(),
        widget.videoPath,
      );

      if (mounted) {
        Get.back(); // or navigate to Homepage
      }
    } catch (e) {
      Get.snackbar("Upload Failed", e.toString());
    } finally {
      if (mounted) setState(() => isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: videoPlayerController.value.isInitialized
          ? SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height / 1.4,
                    child: VideoPlayer(videoPlayerController),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    child: Column(
                      children: [
                        TextInputField(
                          controller: songNameController,
                          myIcon: Icons.music_note,
                          myLabelText: "Song Name",
                        ),
                        const SizedBox(height: 20),
                        TextInputField(
                          controller: captionController,
                          myIcon: Icons.closed_caption,
                          myLabelText: "Caption",
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: isUploading ? null : _handleUpload,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: buttoncolor,
                          ),
                          child: Text(
                            isUploading ? "Please Wait..." : "Upload",
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}

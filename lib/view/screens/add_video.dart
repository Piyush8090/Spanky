import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:spanky/constrain.dart';
import 'package:spanky/view/screens/addCaptionScreen.dart';

class AddVideoScreen extends StatelessWidget {
  AddVideoScreen({super.key});

  final ImagePicker _picker = ImagePicker();

  Future<void> pickVideo(ImageSource source) async {
    try {
      final XFile? pickedVideo = await _picker.pickVideo(source: source);

      if (pickedVideo != null) {
        File videoFile = File(pickedVideo.path);

        Get.snackbar(
          "Video Selected",
          "Loaded from ${source.name}",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green.withOpacity(0.8),
          colorText: Colors.white,
        );

        Get.to(
          () => AddCaptionScreen(
            videoFile: videoFile,
            videoPath: pickedVideo.path,
          ),
        );
      } else {
        Get.snackbar(
          "No Video",
          "No video was selected.",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orange.withOpacity(0.8),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to pick video: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    }
  }

  void showVideoSourceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          "Choose video source",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.video_library, color: Colors.blue),
              title: Text("From Gallery"),
              onTap: () {
                Navigator.pop(context);
                Future.microtask(() => pickVideo(ImageSource.gallery));
              },
            ),
            ListTile(
              leading: Icon(Icons.videocam, color: Colors.green),
              title: Text("Use Camera"),
              onTap: () {
                Navigator.pop(context);
                Future.microtask(() => pickVideo(ImageSource.camera));
              },
            ),
            ListTile(
              leading: Icon(Icons.close, color: Colors.red),
              title: Text("Cancel"),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundcolor,
      body: Center(
        child: GestureDetector(
          onTap: () => showVideoSourceDialog(context),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
            decoration: BoxDecoration(
              color: buttoncolor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.upload_file, color: Colors.white),
                SizedBox(width: 10),
                Text(
                  'Upload Video',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

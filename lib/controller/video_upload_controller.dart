import 'dart:io';
import 'package:get/get.dart';
import 'package:spanky/controller/video_preview_controller.dart';
import 'package:spanky/model/video.dart';
import 'package:spanky/view/screens/home.dart';
import 'package:spanky/controller/video_controller.dart';
import 'package:uuid/uuid.dart';
import 'package:video_compress/video_compress.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VideoUploadController extends GetxController {
  static VideoUploadController instance = Get.find();
  final SupabaseClient supabase = Supabase.instance.client;
  var uuid = Uuid();

  // Generate thumbnail
  Future<File> _getThumb(String videoPath) async {
    final thumbnail = await VideoCompress.getFileThumbnail(videoPath);
    return thumbnail;
  }

  // Upload thumbnail to Supabase Storage
  Future<String> _uploadThumbnailToCloudinary(
    String videoPath,
    String id,
    dynamic user,
  ) async {
    final thumbnailFile = await _getThumb(videoPath);
    final ext = thumbnailFile.path.split('.').last;
    final path = '${user.id}/$id.$ext';

    final fileBytes = await thumbnailFile.readAsBytes();

    final response = await supabase.storage
        .from('thumbnails')
        .uploadBinary(
          path,
          fileBytes,
          fileOptions: FileOptions(contentType: 'image/$ext'),
        );

    if (response.isEmpty) {
      throw Exception('Thumbnail upload failed: Upload returned empty path.');
    }

    final imageUrl = supabase.storage.from('thumbnails').getPublicUrl(path);
    return imageUrl;
  }

  // Upload compressed video to Supabase Storage
  Future<String> _uploadVideoToCloudinary(
    String videoPath,
    String id,
    dynamic user,
  ) async {
    File compressedVideo = await _compressVideo(videoPath);
    final ext = compressedVideo.path.split('.').last;
    final path = '${user.id}/videos/$id.$ext';

    final fileBytes = await compressedVideo.readAsBytes();

    final response = await supabase.storage
        .from('videos')
        .uploadBinary(
          path,
          fileBytes,
          fileOptions: FileOptions(contentType: 'video/$ext'),
        );

    if (response.isEmpty) {
      throw Exception('Video upload failed: Upload returned empty path.');
    }

    final videoUrl = supabase.storage.from('videos').getPublicUrl(path);
    return videoUrl;
  }

  // Compress video
  Future<File> _compressVideo(String videoPath) async {
    final compressedVideo = await VideoCompress.compressVideo(
      videoPath,
      quality: VideoQuality.MediumQuality,
      includeAudio: true, //changed here on 7/7/5
      frameRate: 24,
      deleteOrigin: false,
    );

    if (compressedVideo == null || compressedVideo.file == null) {
      throw Exception("Video compression failed.");
    }

    return compressedVideo.file!;
  }


  // Main upload method
  Future<void> uploadVideo(
    String songName,
    String caption,
    String videoPath,
  ) async {
    try {
      String id = uuid.v1();

      // Get user details from Supabase auth + user table
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception("User not logged in");

      final userData = await supabase
          .from('users')
          .select()
          .eq('uid', user.id)
          .maybeSingle(); // ✅ safer

      if (userData == null) {
        throw Exception("User data not found in database.");
      }

      String uid = user.id;
      String username = userData['name'] ?? '';
      String profilePhoto = userData['profile_photo'] ?? '';

      // Upload video
      String videoUrl = await _uploadVideoToCloudinary(videoPath, id, user);
      String thumbnail = await _uploadThumbnailToCloudinary(
        videoPath,
        id,
        user,
      );

      Video video = Video(
        uid: uid,
        username: username,
        videoUrl: videoUrl,
        thumbnail: thumbnail,
        songName: songName,
        shareCount: 0,
        commentCount: 0,
        likes: [],
        profilePic: profilePhoto,
        caption: caption,
        id: id,
      );

      print("✅ Uploading video with profilePic: $profilePhoto");
      print(" 😀😀Uploading video for UID: ${user.id}");
      print("User data: $userData");
      print("video.toJson(): ${video.toJson()}");
print(" 🥶🥶🥵🥵😱 Video fields → UID: $uid, username: $username, profilePhoto: $profilePhoto");

      await supabase.from('videos').insert(video.toJson());

      await Get.find<VideoController>().refreshVideos();



      Get.snackbar(
        "Success",
        "Video uploaded successfully!",
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 2),
      );

      // Wait for snackbar to show
      await Future.delayed(Duration(milliseconds: 1500));

      Get.to(() => Homepage());
      Future.delayed(Duration(milliseconds: 500), () {
        Get.find<VideoController>().onInit(); // or custom method to refresh
      });
    } catch (e, stackTrace) {
      print("Upload error: $e\n$stackTrace");
      Get.snackbar("Upload Failed", e.toString());
    }
  }

  final RxList<Video> _videoList = <Video>[].obs;
  List<Video> get videoList => _videoList;

  List<VideoPreviewController> previewControllers = [];

  Future<void> fetchVideos() async {
    try {
      final response = await supabase.from('videos').select();
      List<Video> videos = response
          .map((item) => Video.fromJson(item))
          .toList();

      // Dispose old controllers
      for (var pc in previewControllers) {
        pc.dispose();
      }

      // Load new ones
      previewControllers = videos
          .map((video) => VideoPreviewController(url: video.videoUrl))
          .toList();

      for (var pc in previewControllers) {
        await pc.initialize();
      }

      _videoList.value = videos;
    } catch (e) {
      print('❌ Fetch videos error: $e');
    }
  }
}

import 'package:get/get.dart';
import 'package:spanky/controller/auth_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:spanky/model/video.dart';

class VideoController extends GetxController {
  final SupabaseClient supabase = Supabase.instance.client;

  // ✅ RxList instead of Rx<List>
  final RxList<Video> videoList = <Video>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchVideos(); // fetch once on startup
  }

  Future<void> fetchVideos() async {
    print("📥 fetchVideos called");
    try {
      final response = await supabase
          .from('videos')
          .select()
          .order('created_at', ascending: false);

      List<Video> videos =
          response.map<Video>((item) => Video.fromJson(item)).toList();

      videos.shuffle(); // ✅ Randomize video order
      videoList.value = videos;
      print("✅ Fetched videos: ${videos.length}");
    } catch (e) {
      print('❌ Fetch videos error: $e');
    }
  }

  Future<void> refreshVideos() async {
    try {
      final response = await supabase.from('videos').select();

      List<Video> videos =
          response.map<Video>((item) => Video.fromJson(item)).toList();

      videos.shuffle();
      videoList.value = videos;
      print("✅ Refreshed videos: ${videos.length}");
    } catch (e) {
      print("❌ Refresh error: $e");
    }
  }

  void likedVideo(String id) async {
    final uid = AuthController.instance.user!.id;

    int index = videoList.indexWhere((video) => video.id == id);
    if (index == -1) return;

    final video = videoList[index];

    // Toggle like
    if (video.likes.contains(uid)) {
      video.likes.remove(uid);
    } else {
      video.likes.add(uid);
    }

    // Update in Supabase
    await supabase
        .from('videos')
        .update({'likes': video.likes})
        .eq('id', id);

    // Update local list
    videoList[index] = video;
    videoList.refresh(); // ✅ Now works
  }

  Future<void> deleteVideo(Video video) async {
    try {
      // 1. Delete from Supabase Storage
      final videoPath = '${video.uid}/videos/${video.id}.mp4';
      await supabase.storage.from('videos').remove([videoPath]);

      final thumbPath = '${video.uid}/${video.id}.jpg';
      await supabase.storage.from('thumbnails').remove([thumbPath]);

      // 2. Delete from videos table
      await supabase.from('videos').delete().eq('id', video.id);

      // 3. Remove from local list
      videoList.removeWhere((v) => v.id == video.id);

      Get.snackbar("Deleted", "Video deleted successfully");
    } catch (e) {
      print("❌ Video deletion failed: $e");
      Get.snackbar("Error", "Failed to delete video");
    }
  }
}

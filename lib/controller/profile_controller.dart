import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileController extends GetxController {
  final SupabaseClient supabase = Supabase.instance.client;

  final Rx<Map<String, dynamic>> _user = Rx<Map<String, dynamic>>({});
  Map<String, dynamic> get user => _user.value;

  final Rx<String> _uid = ''.obs;

  void updateUseId(String uid) {
    _uid.value = uid;
    getUserData();
  }

  Future<void> updateProfileInVideosTable(
    String uid,
    String name,
    String profilePhoto,
  ) async {
    await supabase
        .from('videos')
        .update({'username': name, 'profilepic': profilePhoto})
        .eq('uid', uid);
  }

  Future<void> updateProfileInVideosAndComments(
    String uid,
    String name,
    String profilePhoto,
  ) async {
    await supabase
        .from('videos')
        .update({'username': name, 'profilepic': profilePhoto})
        .eq('uid', uid);

    await supabase
        .from('comments')
        .update({'username': name, 'profilepic': profilePhoto})
        .eq('uid', uid);
  }

  Future<void> getUserData() async {
    try {
      print("User ID: ${_uid.value}");

      final userRes = await supabase
          .from('users')
          .select('name, profile_photo')
          .eq('uid', _uid.value)
          .maybeSingle();

      print("User data: $userRes");

      if (userRes == null) {
        _user.value = {
          'username': 'Anonymous',
          'profilePic':
              'https://st3.depositphotos.com/1767687/16607/v/450/depositphotos_166074422-stock-illustration-default-avatar-profile-icon-grey.jpg',
          'likes': 0,
          'thumbnails': [],
          'videoUrls': [],
        };
        update();
        return;
      }

      final List videoRes = await supabase
          .from('videos')
          .select('likes, thumbnail, video_url')
          .eq('uid', _uid.value);

      print("Fetched videos: $videoRes");

      int totalLikes = 0;
      List<String> thumbnails = [];
      List<String> videoUrls = [];

      for (var video in videoRes) {
        final likesList = video['likes'] as List<dynamic>? ?? [];
        totalLikes += likesList.length;
        thumbnails.add(video['thumbnail']);
        videoUrls.add(video['video_url']);
      }

      _user.value = {
        'username': userRes['name'],
        'profilePic': userRes['profile_photo'],
        'likes': totalLikes,
        'thumbnails': thumbnails,
        'videoUrls': videoUrls,
      };

      update();
    } catch (e) {
      print("Error loading profile: $e");
      _user.value = {
        'username': 'Anonymous',
        'profilePic':
            'https://st3.depositphotos.com/1767687/16607/v/450/depositphotos_166074422-stock-illustration-default-avatar-profile-icon-grey.jpg',
        'likes': 0,
        'thumbnails': [],
        'videoUrls': [],
      };
      update();
    }
  }
}

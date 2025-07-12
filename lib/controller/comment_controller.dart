import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:spanky/model/comment.dart';

class CommentController extends GetxController {
  final SupabaseClient supabase = Supabase.instance.client;

  final Rx<List<Comment>> _comments = Rx<List<Comment>>([]);
  List<Comment> get comments => _comments.value;

  String _postID = '';

  void updatePostID(String id) {
    _postID = id;
    fetchComment();
  }

  Future<void> fetchComment() async {
    try {
      final List data = await supabase
          .from('comments')
          .select()
          .eq('video_id', _postID)
          .order('datePub', ascending: true);

      _comments.value = data.map((item) => Comment.fromMap(item)).toList();
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch comments: $e');
    }
  }

  Future<void> postComment(String commentText) async {
    if (commentText.trim().isEmpty) {
      Get.snackbar("Empty Comment", "Please write something.");
      return;
    }

    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        Get.snackbar("Auth Error", "No user logged in");
        return;
      }

      final userData = await supabase
          .from('users')
          .select('name, profile_photo')
          .eq('uid', user.id)
          .maybeSingle();

      if (userData == null || userData['name'] == null || userData['profile_photo'] == null) {
        Get.snackbar("Error", "User data incomplete or not found");
        return;
      }

      final comment = Comment(
        username: userData['name'],
        comment: commentText.trim(),
        datePub: DateTime.now().toIso8601String(),
        likes: [],
        profilePic: userData['profile_photo'],
        uid: user.id,
        id: 'comment_${DateTime.now().millisecondsSinceEpoch}',
      );

      await supabase.from('comments').insert({
        ...comment.toJson(),
        'video_id': _postID,
      });
      print('Calling RPC to increment comment count for video: $_postID');

await supabase.rpc('increment_comment_count', params: {
  'video_id_input': _postID,
});

      fetchComment();
    } catch (e) {
      Get.snackbar("Error", "Failed to post comment: $e");
    }
  }

  Future<void> likeComment(String commentId) async {
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) return;

    try {
      final data = await supabase
          .from('comments')
          .select('likes')
          .eq('id', commentId)
          .maybeSingle();

      if (data == null) return;

      final List currentLikes = (data['likes'] ?? []).cast<String>();

      final updatedLikes = currentLikes.contains(uid)
          ? currentLikes.where((id) => id != uid).toList()
          : [...currentLikes, uid];

      await supabase
          .from('comments')
          .update({'likes': updatedLikes})
          .eq('id', commentId);

      fetchComment();
    } catch (e) {
      Get.snackbar("Error", "Failed to like comment: $e");
    }
  }
}

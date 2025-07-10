import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:spanky/view/screens/widgets/text_input.dart';
import 'package:timeago/timeago.dart' as timeago;

class CommentScreen extends StatefulWidget {
  final String videoId;
  final void Function()? onCommentAdded;

  const CommentScreen({
    super.key,
    required this.videoId,
    required this.onCommentAdded,
  });

  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  final TextEditingController _commentController = TextEditingController();
  final SupabaseClient supabase = Supabase.instance.client;
  List<dynamic> comments = [];

  @override
  void initState() {
    super.initState();
    fetchComments();
  }

  Future<void> fetchComments() async {
    try {
      final res = await supabase
          .from('comments')
          .select()
          .eq('video_id', widget.videoId)
          .order('datePub', ascending: true);

      setState(() {
        comments = res;
      });
    } catch (e) {
      debugPrint("Fetch comments error: $e");
    }
  }

  Future<void> postComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      final profile = await supabase
          .from('users')
          .select('name, profile_photo')
          .eq('uid', user.id)
          .maybeSingle();

      final comment = {
        'id': 'comment_${DateTime.now().millisecondsSinceEpoch}',
        'video_id': widget.videoId,
        'comment': text,
        'username': profile?['name'] ?? 'Anonymous',
        'profilepic': profile?['profile_photo'] ?? '',
        'datePub': DateTime.now().toIso8601String(),
        'likes': <String>[],
        'uid': user.id,
      };

      await supabase.from('comments').insert(comment);

      _commentController.clear();
      fetchComments();

      widget.onCommentAdded?.call();
    } catch (e) {
      debugPrint("Post comment error: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to post comment")));
    }
  }

  Future<void> toggleLike(String commentId, List? likes) async {
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) return;

    final currentLikes = List<String>.from(likes ?? []);
    final updatedLikes = currentLikes.contains(uid)
        ? currentLikes.where((id) => id != uid).toList()
        : [...currentLikes, uid];

    try {
      await supabase
          .from('comments')
          .update({'likes': updatedLikes})
          .eq('id', commentId);
      await fetchComments();
    } catch (e) {
      debugPrint("Toggle like error: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to like comment")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = supabase.auth.currentUser?.id;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Comments", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: comments.isEmpty
                ? const Center(
                    child: Text(
                      "No comments yet",
                      style: TextStyle(color: Colors.white70),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      final comment = comments[index];
                      final List likeList = comment['likes'] ?? [];
                      final isLiked = likeList.contains(currentUserId);

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(
                            comment['profilepic'] ?? '',
                          ),
                        ),
                        title: Text(
                          comment['username'] ?? 'Unknown',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              comment['comment'] ?? '',
                              style: const TextStyle(color: Colors.white70),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  timeago.format(
                                    DateTime.parse(comment['datePub']),
                                  ),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  "${likeList.length} likes",
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: InkWell(
                          onTap: () =>
                              toggleLike(comment['id'], comment['likes']),
                          child: Icon(
                            isLiked
                                ? Icons.favorite
                                : Icons.favorite_border_outlined,
                            color: isLiked ? Colors.red : Colors.white54,
                          ),
                        ),
                      );
                    },
                  ),
          ),
          const Divider(color: Colors.white24, height: 1),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            color: Colors.black,
            child: Row(
              children: [
                Expanded(
                  child: TextInputField(
                    controller: _commentController,
                    myIcon: Icons.comment,
                    myLabelText: "Write a comment...",
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: postComment,
                  child: const Text(
                    "Send",
                    style: TextStyle(
                      color: Colors.lightBlueAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spanky/controller/video_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:spanky/controller/comment_controller.dart';
import 'package:spanky/view/screens/widgets/text_input.dart';
import 'package:timeago/timeago.dart' as timeago;

final VideoController videoController = Get.put(VideoController());

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

  final CommentController commentController = Get.put(CommentController());

  @override
  void initState() {
    super.initState();
    commentController.updatePostID(widget.videoId);
  }

  void postComment() {
    commentController.postComment(_commentController.text);
    _commentController.clear();
    widget.onCommentAdded?.call();
    // ignore: invalid_use_of_protected_member
    videoController.refresh();
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
      commentController.fetchComment();
    } catch (e) {
      debugPrint("Toggle like error: $e");
      ScaffoldMessenger.of(
        // ignore: use_build_context_synchronously
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
            child: Obx(() {
              final comments = commentController.comments;

              if (comments.isEmpty) {
                return const Center(
                  child: Text(
                    "No comments yet",
                    style: TextStyle(color: Colors.white70),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: comments.length,
                itemBuilder: (context, index) {
                  final comment = comments[index];
                  final isLiked = comment.likes.contains(currentUserId);

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(comment.profilePic),
                    ),
                    title: Text(
                      comment.username,
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
                          comment.comment,
                          style: const TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              timeago.format(DateTime.parse(comment.datePub)),
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              "${comment.likes.length} likes",
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
                      onTap: () => toggleLike(comment.id, comment.likes),
                      child: Icon(
                        isLiked
                            ? Icons.favorite
                            : Icons.favorite_border_outlined,
                        color: isLiked ? Colors.red : Colors.white54,
                      ),
                    ),
                  );
                },
              );
            }),
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

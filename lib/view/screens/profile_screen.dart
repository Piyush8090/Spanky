import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spanky/controller/auth_controller.dart';
import 'package:spanky/controller/profile_controller.dart';
import 'package:spanky/controller/video_controller.dart';
import 'package:spanky/view/screens/chat_detail.dart';
import 'package:spanky/view/screens/profile_edit.dart';
import 'package:spanky/view/screens/widgets/MyVideoPlayer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends StatefulWidget {
  final String uid;
  const ProfileScreen({super.key, required this.uid});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileController profileController = Get.put(ProfileController());
  final AuthController authController = Get.put(AuthController());

  List<int> selectedIndexes = [];
  bool isSelecting = false;

  @override
  void initState() {
    super.initState();
    profileController.updateUseId(widget.uid);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileController>(
      builder: (controller) {
        if (controller.user.isEmpty) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final username = controller.user['username'] ?? 'Unknown';
        final profilePic = controller.user['profilePic'] ?? '';
        final likes = controller.user['likes'] ?? 0;
        final thumbnails = controller.user['thumbnails'] ?? [];
        final videoUrls = controller.user['videoUrls'] ?? [];
        final posts = thumbnails.length;

        final isCurrentUser =
            Supabase.instance.client.auth.currentUser?.id == widget.uid;

        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            elevation: 0,
            title: Text('@$username'),
            centerTitle: true,
            actions: [
              if (isCurrentUser)
                PopupMenuButton<String>(
                  color: Colors.grey[900],
                  onSelected: (value) {
                    if (value == 'edit') {
                      Get.to(() => const EditProfileScreen());
                    } else if (value == 'signout') {
                      authController.signOut();
                    } else if (value == 'select') {
                      setState(() => isSelecting = true);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Text("Edit Profile"),
                    ),
                    const PopupMenuItem(
                      value: 'select',
                      child: Text("Select Videos"),
                    ),
                    const PopupMenuItem(
                      value: 'signout',
                      child: Text("Sign Out"),
                    ),
                  ],
                ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              await profileController.getUserData();
            },
            child: Column(
              children: [
                const SizedBox(height: 20),
                CircleAvatar(
                  radius: 55,
                  backgroundImage: CachedNetworkImageProvider(profilePic),
                ),
                const SizedBox(height: 10),
                Text(
                  '@$username',
                  style: const TextStyle(color: Colors.white, fontSize: 20),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildStat("Posts", posts),
                    const SizedBox(width: 20),
                    _buildStat("Likes", likes),
                  ],
                ),
                const SizedBox(height: 15),
                if (!isCurrentUser)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Get.to(
                          () => ChatDetailPage(
                            username: username,
                            profileUrl: profilePic,
                            receiverId: widget.uid,
                          ),
                        );
                      },
                      icon: const Icon(Icons.message, size: 18),
                      label: const Text("Message"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                if (isCurrentUser && isSelecting && thumbnails.isNotEmpty)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                        ),
                        onPressed: selectedIndexes.isEmpty
                            ? null
                            : () async {
                                final selectedThumbs = selectedIndexes
                                    .map((i) => thumbnails[i] as String)
                                    .toList();
                                Get.defaultDialog(
                                  title: "Delete Selected",
                                  middleText:
                                      "Are you sure you want to delete ${selectedThumbs.length} videos?",
                                  textCancel: "Cancel",
                                  textConfirm: "Delete",
                                  confirmTextColor: Colors.white,
                                  onConfirm: () async {
                                    Navigator.of(context).pop();
                                    await _deleteSelectedVideos(selectedThumbs);
                                    setState(() {
                                      selectedIndexes.clear();
                                      isSelecting = false;
                                    });
                                    Get.snackbar(
                                      "Deleted",
                                      "${selectedThumbs.length} videos deleted successfully",
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor: Colors.black87,
                                      colorText: Colors.white,
                                    );
                                  },
                                );
                              },
                        child: const Text("Delete Selected"),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isSelecting = false;
                            selectedIndexes.clear();
                          });
                        },
                        child: const Text("Cancel"),
                      ),
                    ],
                  ),
                const Divider(color: Colors.white24, height: 30),
                thumbnails.isEmpty
                    ? const Text(
                        "No posts yet",
                        style: TextStyle(color: Colors.white54),
                      )
                    : Expanded(
                        child: GridView.builder(
                          padding: const EdgeInsets.all(8),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                mainAxisSpacing: 8,
                                crossAxisSpacing: 8,
                                childAspectRatio: 9 / 16,
                              ),
                          itemCount: thumbnails.length,
                          itemBuilder: (context, index) {
                            final isSelected = selectedIndexes.contains(index);
                            final thumbnail = thumbnails[index];

                            // Safely get matching video URL
                            String? videoUrl;
                            if (index < videoUrls.length) {
                              videoUrl = videoUrls[index];
                            }

                            return GestureDetector(
                              onTap: () {
                                if (isSelecting) {
                                  setState(() {
                                    isSelected
                                        ? selectedIndexes.remove(index)
                                        : selectedIndexes.add(index);
                                  });
                                } else {
                                  if (videoUrl == null ||
                                      videoUrl.trim().isEmpty) {
                                    Get.snackbar("Error", "Video not found");
                                    return;
                                  }

                                  Get.to(
                                    () => Scaffold(
                                      backgroundColor: Colors.black,
                                      body: Center(
                                        child: MyVideoPlayer(
                                          videoUrl: videoUrl!,
                                          isMuted: false,
                                        ),
                                      ),
                                    ),
                                  );
                                }
                              },
                              onLongPress: () {
                                setState(() => isSelecting = true);
                              },
                              child: Stack(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      image: DecorationImage(
                                        image: CachedNetworkImageProvider(
                                          thumbnail,
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    const Positioned(
                                      top: 6,
                                      right: 6,
                                      child: Icon(
                                        Icons.check_circle,
                                        color: Colors.redAccent,
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _deleteSelectedVideos(List<String> selectedThumbnails) async {
    final supabase = Supabase.instance.client;
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) return;

    final controller = Get.find<ProfileController>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final thumbs = controller.user['thumbnails'] as List;
      final urls = controller.user['videoUrls'] as List;

      for (final thumb in selectedThumbnails) {
        final videoData = await supabase
            .from('videos')
            .select()
            .eq('thumbnail', thumb)
            .eq('uid', uid)
            .maybeSingle();

        if (videoData != null) {
          final videoId = videoData['id'];
          final videoUrl = videoData['video_url'];
          final thumbnailUrl = videoData['thumbnail'];

          final videoPath = Uri.parse(videoUrl).pathSegments.skip(1).join('/');
          final thumbPath = Uri.parse(
            thumbnailUrl,
          ).pathSegments.skip(1).join('/');

          await supabase.from('comments').delete().eq('video_id', videoId);
          await supabase.from('videos').delete().eq('id', videoId);
          await supabase.storage.from('videos').remove([videoPath]);
          await supabase.storage.from('thumbnails').remove([thumbPath]);

          final indexToRemove = thumbs.indexOf(thumbnailUrl);
          if (indexToRemove != -1 && indexToRemove < urls.length) {
            thumbs.removeAt(indexToRemove);
            urls.removeAt(indexToRemove);
          }
        }
      }

      controller.update();
      await Get.find<VideoController>().fetchVideos();
    } catch (e) {
      Get.snackbar("Delete Error", e.toString());
    } finally {
      Navigator.of(context).pop();
    }
  }

  Widget _buildStat(String label, int count) {
    return Column(
      children: [
        Text(
          '$count',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}

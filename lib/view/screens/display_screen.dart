import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:spanky/controller/video_controller.dart';
import 'package:spanky/view/screens/comment_screen.dart';
import 'package:spanky/view/screens/widgets/MyVideoPlayer.dart';
import 'package:spanky/view/screens/widgets/Profile_Button.dart';
import 'package:spanky/controller/auth_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DisplayScreen extends StatelessWidget {
  DisplayScreen({super.key});
  final VideoController videoController = Get.put(VideoController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Obx(() {
        if (videoController.videoList.isEmpty) {
          return const Center(
            child: Text(
              "No videos found.",
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await videoController.fetchVideos();
          },
          color: Colors.white,
          backgroundColor: Colors.black,
          child: PageView.builder(
            scrollDirection: Axis.vertical,
            itemCount: videoController.videoList.length,
            itemBuilder: (context, index) {
              final data = videoController.videoList[index];
              final currentUserId = AuthController.instance.user?.id ?? '';
              final RxBool showVolumeIcon = false.obs;
              final RxBool isMuted = false.obs;

              return GestureDetector(
                onTap: () {
                  isMuted.value = !isMuted.value;
                  showVolumeIcon.value = true;
                  Future.delayed(const Duration(milliseconds: 600), () {
                    showVolumeIcon.value = false;
                  });
                },
                child: Stack(
                  children: [
                    Obx(
                      () => SizedBox(
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        child: MyVideoPlayer(
                          key: ValueKey(data.videoUrl),
                          videoUrl: data.videoUrl,
                          isMuted: isMuted.value,
                        ),
                      ),
                    ),
                    Center(
                      child: Obx(
                        () => AnimatedOpacity(
                          opacity: showVolumeIcon.value ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 300),
                          child: Icon(
                            isMuted.value ? Icons.volume_off : Icons.volume_up,
                            color: Colors.white,
                            size: 60,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            // ignore: deprecated_member_use
                            Colors.black.withOpacity(0.3),
                            Colors.transparent,
                            // ignore: deprecated_member_use
                            Colors.black.withOpacity(0.5),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 20,
                      left: 15,
                      right: 100,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '@${data.username}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            data.caption,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.music_note,
                                color: Colors.white70,
                                size: 16,
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  data.songName,
                                  style: const TextStyle(
                                    color: Colors.white54,
                                    fontSize: 13,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      right: 12,
                      bottom: 80,
                      child: Column(
                        children: [
                          ProfileButton(profilePhotoUrl: data.profilePic),
                          const SizedBox(height: 22),
                          Builder(
                            builder: (_) {
                              final isLiked = data.likes.contains(
                                currentUserId,
                              );
                              return InkWell(
                                onTap: () =>
                                    videoController.likedVideo(data.id),
                                child: Column(
                                  children: [
                                    Icon(
                                      isLiked
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      size: 36,
                                      color: isLiked
                                          ? Colors.pinkAccent
                                          : Colors.white,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "${data.likes.length}",
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 20),
                          InkWell(
                            onTap: () {
                              Get.to(
                                () => CommentScreen(
                                  videoId: data.id,
                                  onCommentAdded: () {
                                    // manually increment comment count in local list
                                    final index = videoController.videoList
                                        .indexWhere(
                                          (video) => video.id == data.id,
                                        );
                                    if (index != -1) {
                                      final video =
                                          videoController.videoList[index];
                                      video.commentCount += 1;
                                      videoController.videoList[index] = video;
                                      videoController.update();
                                    }
                                  },
                                ),
                              );
                            },
                            child: Column(
                              children: [
                                const Icon(
                                  FontAwesomeIcons.commentDots,
                                  color: Colors.white,
                                  size: 28,
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  "${data.commentCount}",
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          InkWell(
                            onTap: () async {
                              final url = data.videoUrl;
                              final shareText = url.isNotEmpty
                                  ? "Check out this awesome video : ${data.videoUrl}"
                                  : "Such a nice video..!";
                              // ignore: deprecated_member_use
                              await Share.share(
                                shareText,
                                subject: 'Nice video..!',
                              );

                              final supabase = Supabase.instance.client;

                              await supabase
                                  .from('videos')
                                  .update({'share_count': data.shareCount + 1})
                                  .eq('id', data.id);

                              videoController
                                  .update(); // or refresh your Obx/controller/etc
                            },
                            child: Column(
                              children: [
                                const Icon(
                                  FontAwesomeIcons.share,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  "${data.shareCount}",
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 25),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      }),
    );
  }
}

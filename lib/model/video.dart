class Video {
  String username;
  String uid;
  String id;
  List<String> likes;
  int commentCount;
  int shareCount;
  String songName;
  String caption;
  String videoUrl;
  String thumbnail;
  String profilePic;

  Video({
    required this.username,
    required this.uid,
    required this.id,
    required this.likes,
    required this.commentCount,
    required this.shareCount,
    required this.songName,
    required this.caption,
    required this.videoUrl,
    required this.thumbnail,
    required this.profilePic,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      username: json['username'] ?? '',
      uid: json['uid'] ?? '',
      id: json['id'] ?? '',
      likes: List<String>.from(json['likes'] ?? []),
      commentCount: json['comment_count'] ?? 0,
      shareCount: json['share_count'] ?? 0,
      songName: json['song_name'] ?? '',
      caption: json['caption'] ?? '',
      videoUrl: json['video_url'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      profilePic: json['profile_pic'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'uid': uid,
      'id': id,
      'likes': likes,
      'comment_count': commentCount,
      'share_count': shareCount,
      'song_name': songName,
      'caption': caption,
      'video_url': videoUrl,
      'thumbnail': thumbnail,
      'profile_pic': profilePic,
    };
  }
  
}

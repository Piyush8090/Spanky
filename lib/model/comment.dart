class Comment {
  final String username;
  final String comment;
  final String datePub;
  final List likes;
  final String profilePic; // still using camelCase in Dart
  final String uid;
  final String id;

  Comment({
    required this.username,
    required this.comment,
    required this.datePub,
    required this.likes,
    required this.profilePic,
    required this.uid,
    required this.id,
  });

   factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      username: map['username'] ?? '',
      comment: map['comment'] ?? '',
      datePub: map['datePub'] ?? '',
      likes: (map['likes'] ?? []).cast<String>(),
      profilePic: map['profilepic'] ?? '', // 👈 change key here too
      uid: map['uid'] ?? '',
      id: map['id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'username': username,
        'comment': comment,
        'datePub': datePub,
        'likes': likes,
        'profilepic': profilePic, // 👈 change key to match Supabase column
        'uid': uid,
        'id': id,
      };

 
}

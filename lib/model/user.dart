class MyUser {
  final String uid;
  final String name;
  final String email;
  final String profilePhoto;

  MyUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.profilePhoto,
  });

  factory MyUser.fromMap(Map<String, dynamic> map) {
    return MyUser(
      uid: map['uid'],
      name: map['name'],
      email: map['email'],
      profilePhoto: map['profile_photo'], // match your column
    );
  }
}

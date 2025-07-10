import 'dart:io';
import 'package:get/get.dart';
import 'package:spanky/view/screens/home.dart';
import 'package:spanky/view/screens/auth/login_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthController extends GetxController {
  static AuthController instance = Get.find();
  final SupabaseClient supabase = Supabase.instance.client;

  final Rx<User?> _user = Rx<User?>(null);
  User? get user => _user.value;

@override
void onReady() async {
  super.onReady();
  _user.value = supabase.auth.currentUser;

  if (_user.value != null) {
    // ✅ Check if the user exists in 'users' table
    final existing = await supabase
        .from('users')
        .select()
        .eq('uid', _user.value!.id)
        .maybeSingle();

    if (existing == null) {
      // ✅ Insert Google user into 'users' table
      final userInfo = _user.value!;
      await supabase.from('users').insert({
        'uid': userInfo.id,
        'email': userInfo.email,
        'name': userInfo.userMetadata?['full_name'] ?? 'Google User',
        'profile_photo': userInfo.userMetadata?['avatar_url'] ??
            'https://st3.depositphotos.com/1767687/16607/v/450/depositphotos_166074422-stock-illustration-default-avatar-profile-icon-grey.jpg',
      });
    }
      Supabase.instance.client.auth.onAuthStateChange.listen((data) {
    _user.value = data.session?.user;
    if (_user.value != null) {
      Get.offAll(() => const Homepage());
    }
  });
  }

  // 🔁 Keep auth listener
  supabase.auth.onAuthStateChange.listen((data) {
    _user.value = data.session?.user;
  });
}


  Future<String> uploadImage(File file, String uid) async {
    final fileBytes = await file.readAsBytes();
    final ext = file.path.split('.').last;
    final path = 'profilepics/$uid.$ext';

    final response = await supabase.storage
        .from('profilepics')
        .uploadBinary(
          path,
          fileBytes,
          fileOptions: FileOptions(contentType: 'image/$ext'),
        );

    if (response.isEmpty) {
      throw Exception('Image upload failed.');
    }

    final imageUrl = supabase.storage.from('profilepics').getPublicUrl(path);
    return imageUrl;
  }

  Future<void> signUpUser({
    required String name,
    required String email,
    required String password,
    required File profilePhoto,
  }) async {
    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) throw Exception('User signup failed');

      String photoUrl = await uploadImage(profilePhoto, user.id);

      await supabase.from('users').insert({
        'uid': user.id,
        'name': name,
        'email': email,
        'profile_photo': photoUrl, //changed 7/7/5
      });

      Get.snackbar('Success', 'Account created. Please verify your email.');
    } catch (e) {
      print('Signup Error: $e');
      Get.snackbar('Signup Failed', e.toString());
    }
  }

 Future<void> signInWithGoogle() async {
  try {
    await Supabase.instance.client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'io.supabase.flutter://login-callback/',
    );
    // Don't add another call after this — Supabase handles redirect.
  } catch (e) {
    print('Google SignIn Error: $e');
    Get.snackbar('Google SignIn Failed', e.toString());
  }
}
Future<void> signOut() async {
  try {
    // Global sign out (includes OAuth like Google)
    await supabase.auth.signOut(scope: SignOutScope.global);
    Get.snackbar('Signed Out', 'You have been logged out.');
    Get.offAll(() => LoginScreen());
  } catch (e) {
    print('SignOut Error: $e');
    Get.snackbar('Sign Out Failed', e.toString());
  }
}

}

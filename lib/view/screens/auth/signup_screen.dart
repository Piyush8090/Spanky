import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'package:spanky/view/screens/auth/login_screen.dart';
import 'package:spanky/view/screens/widgets/text_input.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final supabase = Supabase.instance.client;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _setpasswordController = TextEditingController();
  final TextEditingController _confirmpasswordController =
      TextEditingController();

  File? _profileImage;
  bool isLoading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _profileImage = File(picked.path);
      });
    }
  }

  Future<void> _signUp() async {
    final email = _emailController.text.trim();
    final password = _setpasswordController.text.trim();
    final confirm = _confirmpasswordController.text.trim();
    final username = _usernameController.text.trim();

    if (email.isEmpty || password.isEmpty || username.isEmpty) {
      Get.snackbar("Error", "Email, username, and password are required");
      return;
    }

    if (password != confirm) {
      Get.snackbar("Error", "Passwords do not match");
      return;
    }

    setState(() => isLoading = true);

    try {
      final AuthResponse response = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        Get.snackbar("Error", "User signup failed");
        return;
      }

      String publicURL =
          "https://st3.depositphotos.com/1767687/16607/v/450/depositphotos_166074422-stock-illustration-default-avatar-profile-icon-grey.jpg";

      if (_profileImage != null) {
        final fileExt = _profileImage!.path.split('.').last;
        final filePath = 'profile/${user.id}/profilepics.$fileExt';

        await supabase.auth.refreshSession();

        await supabase.storage.from('profilepics').upload(
              filePath,
              _profileImage!,
              fileOptions: const FileOptions(upsert: true),
            );

        publicURL = supabase.storage.from('profilepics').getPublicUrl(filePath);
      }

      final existingUser = await supabase
    .from('users')
    .select('uid')
    .eq('uid', user.id)
    .maybeSingle();

if (existingUser == null) {
  await supabase.from('users').insert({
    'uid': user.id,
    'email': email,
    'name': username,
    'profile_photo': publicURL,
  });
} else {
  print("User already exists, skipping insert.");
}


      Get.snackbar("Success", "Check your email to verify your account");
      Navigator.pop(context);
    } catch (e) {
      Get.snackbar("Signup Failed", e.toString());
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Create Account",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Join Spanky to share and explore videos",
                style: TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              // Profile image
              InkWell(
                onTap: _pickImage,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 55,
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : const NetworkImage(
                              "https://st3.depositphotos.com/1767687/16607/v/450/depositphotos_166074422-stock-illustration-default-avatar-profile-icon-grey.jpg",
                            ) as ImageProvider,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: const Icon(Icons.edit, size: 18, color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              TextInputField(
                controller: _emailController,
                myLabelText: "Email",
                myIcon: Icons.email_outlined,
              ),
              const SizedBox(height: 20),

              TextInputField(
                controller: _usernameController,
                myLabelText: "Username",
                myIcon: Icons.person_outline,
              ),
              const SizedBox(height: 20),

              TextInputField(
                controller: _setpasswordController,
                myLabelText: "Set Password",
                myIcon: Icons.lock_outline,
                toHide: true,
              ),
              const SizedBox(height: 20),

              TextInputField(
                controller: _confirmpasswordController,
                myLabelText: "Confirm Password",
                myIcon: Icons.lock_outline,
                toHide: true,
              ),
              const SizedBox(height: 30),

              // Sign up button
              ElevatedButton(
                onPressed: isLoading ? null : _signUp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Sign Up", style: TextStyle(fontSize: 16)),
              ),

              const SizedBox(height: 25),

              // Already have account
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account? ",
                      style: TextStyle(color: Colors.white70)),
                  GestureDetector(
                    onTap: () => Get.off(() => const LoginScreen()),
                    child: const Text(
                      "Login",
                      style: TextStyle(
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

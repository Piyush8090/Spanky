import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:spanky/controller/profile_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  final _nameController = TextEditingController();
  File? _pickedImage;

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _pickedImage = File(picked.path));
    }
  }
  

  Future<void> _saveChanges() async {
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) return;

    String? uploadedUrl;
    if (_pickedImage != null) {
      final path = 'profile/$uid/profile.jpg';
      final bytes = await _pickedImage!.readAsBytes();
      await supabase.storage
          .from('profilepics')
          .uploadBinary(
            path,
            bytes,
            fileOptions: const FileOptions(upsert: true),
          );
      uploadedUrl = supabase.storage.from('profilepics').getPublicUrl(path);
    }

    final newName = _nameController.text.trim();
    final updates = <String, dynamic>{};
    if (newName.isNotEmpty) updates['name'] = newName;
    if (uploadedUrl != null) updates['profile_photo'] = uploadedUrl;

    if (updates.isNotEmpty) {
      await supabase.from('users').update(updates).eq('uid', uid);

      final videoUpdate = <String, dynamic>{};
      if (newName.isNotEmpty) videoUpdate['username'] = newName;
      if (uploadedUrl != null) videoUpdate['profile_pic'] = uploadedUrl;
      if (videoUpdate.isNotEmpty) {
        await supabase.from('videos').update(videoUpdate).eq('uid', uid);
      }

      final commentUpdate = <String, dynamic>{};
      if (newName.isNotEmpty) commentUpdate['username'] = newName;
      if (uploadedUrl != null) commentUpdate['profilepic'] = uploadedUrl;
      if (commentUpdate.isNotEmpty) {
        await supabase.from('comments').update(commentUpdate).eq('uid', uid);
      }

      await Get.find<ProfileController>().getUserData();
      Get.back();
    }
  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text("Edit Profile")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _pickedImage != null
                    ? FileImage(_pickedImage!)
                    : null,
                child: _pickedImage == null
                    ? const Icon(Icons.camera_alt, color: Colors.white)
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Display Name',
                labelStyle: TextStyle(color: Colors.grey),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white24),
                ),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _saveChanges,
              child: const Text("Save Changes"),
            ),
          ],
        ),
      ),
    );
  }
  
}


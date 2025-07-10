import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spanky/view/screens/add_video.dart';
import 'package:spanky/view/screens/display_screen.dart';
import 'package:spanky/view/screens/message_screen.dart';
import 'package:spanky/view/screens/nav_bar.dart';
import 'package:spanky/view/screens/profile_screen.dart';
import 'package:spanky/view/screens/search_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:spanky/controller/profile_controller.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int pageIdx = 0;

  final currentUser = Supabase.instance.client.auth.currentUser;

  late List<Widget> pageindex;

  @override
  void initState() {
    super.initState();

    final uid = Supabase.instance.client.auth.currentUser!.id;

    // Update UID before loading ProfileScreen
    final profileController = Get.put(ProfileController());
    profileController.updateUseId(uid);

    pageindex = [
      DisplayScreen(),
      SearchScreen(),
      AddVideoScreen(),
      MessageScreen(),
      const SizedBox(), // Temporary placeholder for ProfileScreen
    ];

    // Load ProfileScreen after a microtask
    Future.microtask(() {
      setState(() {
        pageindex[4] = ProfileScreen(uid: uid);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: false,
      body: pageindex[pageIdx],
      bottomNavigationBar: NavBarBottom(
        currentIndex: pageIdx,
        onTap: (index) {
          setState(() {
            pageIdx = index;
          });
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:spanky/view/screens/chat_detail.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final supabase = Supabase.instance.client;
  List<dynamic> chatList = [];
  bool loading = true;
  bool fetchedOnce = false;

  String get currentUserId => supabase.auth.currentUser!.id;

  @override
  void initState() {
    super.initState();
    fetchChatUsers();
  }

  Future<void> fetchChatUsers() async {
    try {
      final response = await supabase.rpc(
        'get_last_messages_for_user',
        params: {'user_id': currentUserId},
      );

      setState(() {
        chatList = response ?? [];
        loading = false;
        fetchedOnce = true;
      });
    } catch (e) {
      setState(() {
        chatList = [];
        loading = false;
        fetchedOnce = true;
      });
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Messages',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 1,
      ),
      body: !fetchedOnce
          ? Container(color: Colors.black) // Black screen initially
          : loading
          ? const Center(child: CircularProgressIndicator())
          : chatList.isEmpty
          ? const Center(
              child: Text(
                "No messages yet.",
                style: TextStyle(color: Colors.white70),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              itemCount: chatList.length,
              itemBuilder: (context, index) {
                final user = chatList[index];

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    tileColor: Colors.grey[900],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    leading: CircleAvatar(
                      radius: 25,
                      backgroundImage: NetworkImage(
                        user['profile_photo'] ?? "",
                      ),
                    ),
                    title: Text(
                      user['name'] ?? "User",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      user['message'] ?? "",
                      style: const TextStyle(color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () async {
                      final result = await Get.to(
                        () => ChatDetailPage(
                          username: user['name'],
                          profileUrl: user['profile_photo'],
                          receiverId: user['uid'],
                        ),
                      );

                      if (result == true) {
                        fetchChatUsers(); // reload messages list after message sent
                      }
                    },
                  ),
                );
              },
            ),
    );
  }
}

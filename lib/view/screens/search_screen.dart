import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spanky/controller/searchUser_controller.dart';
import 'package:spanky/model/user.dart';
import 'package:spanky/view/screens/profile_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController searchQuery = TextEditingController();
  final SearchUserController searchController = Get.put(SearchUserController());

  @override
  void dispose() {
    searchQuery.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.black,
        title: Container(
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextFormField(
            controller: searchQuery,
            style: const TextStyle(color: Colors.white),
            onChanged: (_) => setState(() {}),
            onFieldSubmitted: (value) {
              if (value.trim().isNotEmpty) {
                searchController.searchUser(value.trim());
              }
            },
            decoration: InputDecoration(
              hintText: "Search username",
              hintStyle: TextStyle(color: Colors.grey[500]),
              border: InputBorder.none,
              prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
              suffixIcon: searchQuery.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () {
                        searchQuery.clear();
                        searchController.clearResults();
                        setState(() {});
                      },
                    )
                  : null,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            ),
          ),
        ),
      ),
      body: Obx(() {
        final users = searchController.searchedUsers;

        if (searchController.isLoading.value) {
          return const Center(
              child: CircularProgressIndicator(color: Colors.white));
        }

        if (users.isEmpty) {
          return const Center(
            child: Text("Search users!",
                style: TextStyle(color: Colors.grey, fontSize: 16)),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 10),
          itemCount: users.length,
          separatorBuilder: (_, __) =>
              const Divider(color: Colors.white12, indent: 75, endIndent: 15),
          itemBuilder: (context, index) {
            final MyUser user = users[index];
            return ListTile(
              onTap: () => Get.to(() => ProfileScreen(uid: user.uid)),
              leading: CircleAvatar(
                backgroundImage: NetworkImage(user.profilePhoto),
                radius: 25,
              ),
              title: Text(
                user.name,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, color: Colors.white),
              ),
            );
          },
        );
      }),
    );
  }
}

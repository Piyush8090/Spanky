import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:spanky/model/user.dart';

class SearchUserController extends GetxController {
  final Rx<List<MyUser>> _searchUsers = Rx<List<MyUser>>([]);
  List<MyUser> get searchedUsers => _searchUsers.value;
  final RxBool isLoading = false.obs;

  void clearResults() {
  _searchUsers.value = [];
}

  Future<void> searchUser(String query) async {
    try {
      isLoading.value = true;

      final response = await Supabase.instance.client
          .from('users')
          .select()
          .ilike('name', '%$query%');

      _searchUsers.value = response
          .map<MyUser>((item) => MyUser.fromMap(item))
          .toList();
    } catch (e) {
      print("Search error: $e");
    } finally {
      isLoading.value = false;
    }
  }
}

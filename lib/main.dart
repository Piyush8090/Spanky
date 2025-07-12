import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spanky/view/screens/home.dart';
import 'package:spanky/view/screens/auth/login_screen.dart';
import 'package:spanky/controller/video_controller.dart';
import 'package:spanky/view/screens/splash_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:spanky/controller/auth_controller.dart';
import 'package:spanky/constrain.dart';
import 'secrets.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: Secrets.supabaseUrl,
    anonKey: Secrets.supabaseAnonKey,
    
  );

  // Register controller with GetX
  Get.put(AuthController());
  Get.put(VideoController());
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
       theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: backgroundcolor
      ),
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

class AuthCheck extends StatelessWidget {
  const AuthCheck({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    if (user !=null) {
      return const  Homepage();
    } else {
      return const LoginScreen();
    }
  }
}

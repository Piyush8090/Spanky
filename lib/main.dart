import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spanky/view/screens/home.dart';
import 'package:spanky/view/screens/auth/login_screen.dart';
import 'package:spanky/controller/video_controller.dart';
import 'package:spanky/view/screens/splash_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:spanky/controller/auth_controller.dart';
import 'package:spanky/constrain.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://uwtpuvrjylkklgwwlayp.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InV3dHB1dnJqeWxra2xnd3dsYXlwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE0NTQ3NTcsImV4cCI6MjA2NzAzMDc1N30.drzR9QyOhcdkbEuW8qV_ovR_R05KANikHa90NRxR0rI',
    
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

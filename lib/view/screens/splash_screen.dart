
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:spanky/main.dart';


class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // return Center(child: Lottie.asset('assets/bear_anim.json'));
    return AnimatedSplashScreen(
      splash: Center(child: Lottie.asset('assets/bear_anim.json')),
      nextScreen: const AuthCheck(),
      splashIconSize: 250,
      duration: 3000,
      splashTransition: SplashTransition.fadeTransition,
      backgroundColor: Colors.white,
    );
  }
}

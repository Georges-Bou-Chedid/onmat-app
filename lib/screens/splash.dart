import 'dart:async';
import 'package:onmat/utils/helpers/helper_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/constants/sizes.dart';
import 'authentication/log_in.dart';
import 'instructor/home/home.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _startApp();
  }

  void _startApp() async {
    await Future.delayed(const Duration(seconds: 3)); // splash delay

    final user = FirebaseAuth.instance.currentUser;

    // Make sure we navigate AFTER current frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (user != null) {
        FirebaseAuth.instance.signOut();
        // Get.offAll(() => const HomePageScreen());
      } else {
        Get.offAll(() => const LoginInScreen());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);

    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            'assets/images/fitness_background.jpg',
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
          Container(
            color: dark
                ? const Color(0xFF1E1E1E).withOpacity(0.6)
                : const Color(0xFFECEFF1).withOpacity(0.9),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  'assets/images/demo-logo.png',
                  width: 150.0,
                  height: 150.0,
                ),
                const SizedBox(height: TSizes.spaceBtwItems),
                const SizedBox(
                  height: TSizes.lg,
                  width: TSizes.lg,
                  child: CircularProgressIndicator(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
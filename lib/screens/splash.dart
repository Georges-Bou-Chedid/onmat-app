import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:onmat/screens/instructor/settings/settings.dart';
import 'package:provider/provider.dart';
import '../controllers/user.dart';
import '../utils/constants/sizes.dart';
import 'authentication/login/login.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (user != null) {
        final UserAccountService userAccountService = Provider.of<UserAccountService>(context, listen: false);
        final success = await userAccountService.fetchAndSetUser(user.uid);

        if (success) {
          if (userAccountService.userAccount!.role == 'instructor') {
            Get.offAll(() => const SettingsScreen());
          }
        } else {
          Get.offAll(() => const LoginScreen()); // or onboarding
        }
      } else {
        Get.offAll(() => const LoginScreen());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDF1E42),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'assets/images/logo-white.png',
              width: 180.0,
              height: 180.0,
            ),
            const SizedBox(height: TSizes.spaceBtwSections),
            const SizedBox(
              height: TSizes.lg,
              width: TSizes.lg,
              child: CircularProgressIndicator(),
            ),
          ],
        ),
      ),
    );
  }
}
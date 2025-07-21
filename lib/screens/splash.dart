import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../controllers/auth.dart';
import '../controllers/instructor.dart';
import '../controllers/student.dart';
import '../utils/constants/sizes.dart';
import 'authentication/login/login.dart';
import 'instructor/start.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthService _authService = AuthService();
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_started) {
      _started = true;
      _startApp();
    }
  }

  void _startApp() async {
    Future.wait([
      precacheImage(const AssetImage('assets/images/dashboard_background.jpg'), context),
      precacheImage(const AssetImage('assets/images/create_class_background.jpg'), context),
      precacheImage(const AssetImage('assets/images/class_details_background.jpg'), context),
    ]);

    await Future.delayed(const Duration(seconds: 3)); // splash delay

    // Make sure we navigate AFTER current frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        Get.offAll(() => const LoginScreen());
        return;
      }

      final instructorService = Provider.of<InstructorService>(context, listen: false);
      final studentService = Provider.of<StudentService>(context, listen: false);

      final isInstructor = await instructorService.fetchAndSetInstructor(user.uid);
      if (isInstructor) {
        Get.offAll(() => const StartScreen()); // Instructor dashboard
        return;
      }

      final isStudent = await studentService.fetchAndSetStudent(user.uid);
      if (isStudent) {
        await _authService.signOut();
        Get.offAll(() => const LoginScreen()); // or student dashboard
        return;
      }

      // If user not found in either collection
      await user.delete();
      await _authService.signOut();
      Get.offAll(() => const LoginScreen());
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
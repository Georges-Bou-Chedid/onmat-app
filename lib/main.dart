import 'package:onmat/controllers/instructor_class.dart';
import 'package:onmat/controllers/instructor.dart';
import 'package:onmat/screens/splash.dart';
import 'package:onmat/utils/theme_data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'controllers/class_assistant.dart';
import 'controllers/auth.dart';
import 'controllers/student.dart';
import 'firebase_options.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final prefs = await SharedPreferences.getInstance();
  final savedCode = prefs.getString('lang');
  final startLocale = savedCode != null
      ? Locale(savedCode)
      : Get.deviceLocale ?? const Locale('en');
  runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => InstructorService()),
          ChangeNotifierProvider(create: (_) => StudentService()),
          ChangeNotifierProvider(create: (_) => InstructorClassService()),
          ChangeNotifierProvider(create: (_) => ClassAssistantService()),
        ],
        child: MyApp(startLocale),
      )
  );
}

class MyApp extends StatefulWidget {
  const MyApp(this.initialLocale, {super.key});
  final Locale initialLocale;

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return StreamProvider<User?>.value(
      value: AuthService().user,
      initialData: null,
      child: GetMaterialApp(
        locale: widget.initialLocale,
        fallbackLocale: Locale('en'),
        supportedLocales: const [
          Locale('en'),
          Locale('ar'),
        ],
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        themeMode: ThemeMode.system,
        theme: lightTheme(),
        darkTheme: darkTheme(),
        home: SplashScreen(),
      ),
    );
  }
}

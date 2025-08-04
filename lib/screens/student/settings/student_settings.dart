import 'package:get/get.dart';
import 'package:onmat/controllers/auth.dart';
import 'package:onmat/screens/student/settings/student_account_security.dart';
import 'package:onmat/screens/student/settings/student_support_legal.dart';
import 'package:onmat/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:onmat/utils/widgets/primary_header_container.dart';
import 'package:onmat/utils/widgets/settings_menu_tile.dart';
import 'package:provider/provider.dart';

import '../../../controllers/student/student.dart';
import '../../../l10n/app_localizations.dart';
import '../../../utils/widgets/circular_image.dart';
import '../../../utils/widgets/section_header.dart';
import '../../splash.dart';
import 'student_app_preferences.dart';
import 'student_edit_profile.dart';

class StudentSettingsScreen extends StatefulWidget {
  const StudentSettingsScreen({super.key});

  @override
  _StudentSettingsScreenState createState() => _StudentSettingsScreenState();
}

class _StudentSettingsScreenState extends State<StudentSettingsScreen> {
  late AppLocalizations appLocalizations;

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();
    final StudentService studentService = Provider.of<StudentService>(context, listen: true);
    final student = studentService.student;
    appLocalizations = AppLocalizations.of(context)!;

    return Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              /// -- Header
              TPrimaryHeaderContainer(
                child: Column(
                  children: [
                    /// AppBar
                    Container(
                      height: 150, // enough height for your image
                      padding: EdgeInsets.only(top: TSizes.defaultSpace, left: 20, right: 20),
                      alignment: Alignment.centerLeft,
                      child: Image.asset(
                        'assets/images/logo-white.png',
                        width: 80,
                        height: 80,
                        fit: BoxFit.contain,
                      ),
                    ),

                    /// User Profile Card
                    ListTile(
                      leading: TCircularImage(
                        image: "assets/images/settings/user.png",
                        width: 50,
                        height: 50,
                        padding: 0,
                      ),
                      title: Text(
                          student != null
                          ? "${student.firstName} ${student.lastName}"
                          : '',
                        style: Theme.of(context).textTheme.headlineSmall!.apply(color: Colors.white)
                      ),
                      subtitle: Text(
                        student!.email ?? '',
                        style: Theme.of(context).textTheme.bodyMedium!.apply(color: Colors.white)
                      ),
                      trailing: IconButton(
                        onPressed: (){
                          Get.to(
                            () => const StudentEditProfilePage(),
                            transition: Transition.downToUp,        // comes from bottom, exits at top
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,               // optional: smoother easing
                          );
                        },
                        icon: const Icon(Iconsax.edit, color: Colors.white)
                      ),
                    ),
                    const SizedBox(height: TSizes.spaceBtwSections)
                  ],
                ),
              ),

              /// Body
              Padding(
                padding: const EdgeInsets.all(TSizes.defaultSpace),
                child: Column(
                  children: [
                    /// Account Settings
                    TSectionHeading(title: appLocalizations.accountSettings, showActionButton: false),
                    SizedBox(height: TSizes.spaceBtwItems),

                    TSettingsMenuTile(
                      icon: Iconsax.setting_2,
                      title: appLocalizations.appPreferences,
                      subTitle: appLocalizations.appPreferencesSub,
                      onTap: () {
                        Get.to(
                          () => const StudentAppPreferencesPage(),
                          transition: Transition.downToUp,        // comes from bottom, exits at top
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,               // optional: smoother easing
                        );
                      },
                    ),
                    TSettingsMenuTile(
                      icon: Iconsax.security,
                      title: appLocalizations.accountAndSecurity,
                      subTitle: appLocalizations.accountAndSecuritySub,
                      onTap: () {
                        Get.to(
                          () => const StudentAccountSecurityPage(),
                          transition: Transition.downToUp,        // comes from bottom, exits at top
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,               // optional: smoother easing
                        );
                      },
                    ),
                    TSettingsMenuTile(
                      icon: Iconsax.support,
                      title: appLocalizations.supportAndLegal,
                      subTitle: appLocalizations.supportAndLegalSub,
                      onTap: () {
                        Get.to(
                          () => const StudentSupportLegalPage(),
                          transition: Transition.downToUp,        // comes from bottom, exits at top
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,               // optional: smoother easing
                        );
                      },
                    ),


                    /// Logout Button
                    const SizedBox(height: TSizes.spaceBtwSections),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                          onPressed: () async {
                            await showDialog(
                              context: context,
                              barrierDismissible: true,
                              builder: (context) => AlertDialog(
                                title: Text(appLocalizations.confirmLogout),
                                content: Text(appLocalizations.confirmLogoutText),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(false),
                                    child: Text(appLocalizations.cancel),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => Navigator.of(context).pop(true),
                                    child: Text(appLocalizations.logout),
                                  ),
                                ],
                              ),
                            ).then((confirmed) async {
                              if (confirmed == true) {
                                await authService.signOut();
                                Get.offAll(() => const SplashScreen());
                              }
                            });
                          },
                          child: Text(appLocalizations.logout)
                      )
                    ),
                    const SizedBox(height: TSizes.spaceBtwSections * 2.5)
                  ],
                ),
              )
            ],
          ),
        )
    );
  }
}

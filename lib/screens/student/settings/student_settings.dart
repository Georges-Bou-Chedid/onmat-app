import 'package:get/get.dart';
import 'package:onmat/controllers/auth.dart';
import 'package:onmat/screens/student/settings/student_account_security.dart';
import 'package:onmat/screens/student/settings/student_support_legal.dart';
import 'package:onmat/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:onmat/utils/helpers/helper_functions.dart';
import 'package:provider/provider.dart';

import '../../../controllers/notification_service.dart';
import '../../../controllers/student/student.dart';
import '../../../l10n/app_localizations.dart';
import '../../../utils/widgets/circular_image.dart';
import '../../splash.dart';
import 'student_app_preferences.dart';
import 'student_edit_profile.dart';

class StudentSettingsScreen extends StatefulWidget {
  const StudentSettingsScreen({super.key});

  @override
  _StudentSettingsScreenState createState() => _StudentSettingsScreenState();
}

class _StudentSettingsScreenState extends State<StudentSettingsScreen> {
  // SYNCED BRAND COLOR
  final Color primaryBrandColor = const Color(0xFFDF1E42);

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();
    final StudentService studentService = Provider.of<StudentService>(context, listen: true);
    final student = studentService.student;
    final appLocalizations = AppLocalizations.of(context)!;
    final dark = THelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: dark ? Colors.black : Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Iconsax.arrow_left_2, color: dark ? Colors.white : Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Text(
          appLocalizations.accountSettings,
          style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: TSizes.spaceBtwSections),

            /// --- CENTERED PROFILE HEADER (STUDENT) ---
            Column(
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: primaryBrandColor, width: 2),
                      ),
                      child: TCircularImage(
                        // SYNCED IMAGE LOGIC
                        image: (student?.profilePicture != null && student!.profilePicture!.isNotEmpty)
                            ? student.profilePicture!
                            : "assets/images/settings/user.png",
                        width: 100,
                        height: 100,
                        padding: 0,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Get.to(() => const StudentEditProfilePage(), transition: Transition.downToUp),
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: primaryBrandColor,
                        child: const Icon(Iconsax.edit_2, color: Colors.white, size: 16),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: TSizes.spaceBtwItems),
                Text(
                  student != null ? "${student.firstName} ${student.lastName}" : 'Student Name',
                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  student?.email ?? 'student@example.com',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.grey),
                ),
              ],
            ),

            const SizedBox(height: TSizes.spaceBtwSections),

            /// --- SETTINGS TILES (GROUPED) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: TSizes.defaultSpace),
              child: Column(
                children: [
                  _buildSettingsGroup(
                    context,
                    dark,
                    [
                      _buildMenuTile(
                        icon: Iconsax.setting_2,
                        title: appLocalizations.appPreferences,
                        subtitle: appLocalizations.appPreferencesSub,
                        onTap: () => Get.to(() => const StudentAppPreferencesPage(), transition: Transition.rightToLeft),
                      ),
                      _buildMenuTile(
                        icon: Iconsax.security,
                        title: appLocalizations.accountAndSecurity,
                        subtitle: appLocalizations.accountAndSecuritySub,
                        onTap: () => Get.to(() => const StudentAccountSecurityPage(), transition: Transition.rightToLeft),
                      ),
                      _buildMenuTile(
                        icon: Iconsax.support,
                        title: appLocalizations.supportAndLegal,
                        subtitle: appLocalizations.supportAndLegalSub,
                        onTap: () => Get.to(() => const StudentSupportLegalPage(), transition: Transition.rightToLeft),
                      ),
                    ],
                  ),

                  const SizedBox(height: TSizes.spaceBtwSections),

                  /// --- LOGOUT BUTTON ---
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: primaryBrandColor,
                        side: BorderSide(color: primaryBrandColor),
                        padding: const EdgeInsets.symmetric(vertical: TSizes.md),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => _confirmLogout(context, authService, appLocalizations),
                      child: Text(appLocalizations.logout, style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: TSizes.spaceBtwSections),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Helper: Card wrapper for tiles
  Widget _buildSettingsGroup(BuildContext context, bool dark, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: dark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(children: children),
    );
  }

  /// Helper: Synced Menu Tile
  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: primaryBrandColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: primaryBrandColor, size: 22),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: const Icon(Iconsax.arrow_right_3, size: 18, color: Colors.grey),
    );
  }

  /// Helper: Styled Logout Dialog
  void _confirmLogout(BuildContext context, AuthService authService, AppLocalizations appLocalizations) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(appLocalizations.confirmLogout),
        content: Text(appLocalizations.confirmLogoutText),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(appLocalizations.cancel)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primaryBrandColor),
            onPressed: () async {
              // 1. Stop notification listener and reset count
              Provider.of<NotificationService>(context, listen: false).stopListening();
              await authService.signOut();
              Get.offAll(() => const SplashScreen());
            },
            child: Text(appLocalizations.logout, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
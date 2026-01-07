import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

import '../../../controllers/auth.dart';
import '../../../controllers/student/student.dart';
import '../../../l10n/app_localizations.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/helpers/helper_functions.dart';

class StudentAppPreferencesPage extends StatefulWidget {
  const StudentAppPreferencesPage({super.key});

  @override
  State<StudentAppPreferencesPage> createState() => _StudentAppPreferencesPageState();
}

class _StudentAppPreferencesPageState extends State<StudentAppPreferencesPage> {
  final Color primaryBrandColor = const Color(0xFFDF1E42);

  void showLanguageDialog(BuildContext context, AppLocalizations l10n, AuthService auth) {
    final locale = l10n.localeName;
    String tempSelection = locale;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        // REMOVING THE THEME BORDER LOCALLY
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide.none,
        ),
        title: Text(l10n.changeLanguage, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: StatefulBuilder(
          builder: (ctx, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLanguageOption(
                context,
                title: 'English',
                value: 'en',
                flag: 'assets/images/english.png',
                groupValue: tempSelection,
                onChanged: (val) => setState(() => tempSelection = val!),
              ),
              const Divider(height: 1, indent: 10, endIndent: 10),
              _buildLanguageOption(
                context,
                title: 'العربية',
                value: 'ar',
                flag: 'assets/images/arabic.png',
                groupValue: tempSelection,
                onChanged: (val) => setState(() => tempSelection = val!),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primaryBrandColor),
            onPressed: () {
              Navigator.pop(ctx);
              auth.applyLocale(tempSelection);
            },
            child: Text(l10n.ok, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(BuildContext context, {required String title, required String value, required String flag, required String groupValue, required ValueChanged<String?> onChanged}) {
    return RadioListTile<String>(
      activeColor: primaryBrandColor,
      contentPadding: EdgeInsets.zero,
      title: Row(
        children: [
          ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.asset(flag, width: 24, height: 18, fit: BoxFit.cover)
          ),
          const SizedBox(width: 12),
          Text(title, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();
    final studentService = Provider.of<StudentService>(context);
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
          appLocalizations.appPreferences,
          style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          children: [
            /// --- PREFERENCES CONTAINER ---
            Container(
              decoration: BoxDecoration(
                color: dark ? Colors.grey[900] : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))
                ],
              ),
              child: Column(
                children: [
                  /// Language
                  _buildMenuTile(
                    icon: Iconsax.global,
                    title: appLocalizations.language,
                    subtitle: appLocalizations.languageSub,
                    onTap: () => showLanguageDialog(context, appLocalizations, authService),
                    trailing: const Icon(Iconsax.arrow_right_3, size: 18, color: Colors.grey),
                  ),

                  const Divider(indent: 50, endIndent: 20, height: 1),

                  /// Notifications
                  _buildMenuTile(
                    icon: Iconsax.notification,
                    title: appLocalizations.notifications,
                    subtitle: appLocalizations.notificationsSub,
                    onTap: null,
                    trailing: Transform.scale(
                      scale: 0.8,
                      child: Switch(
                        activeColor: primaryBrandColor,
                        value: student?.notifications ?? false,
                        onChanged: (value) async {
                          final success = await studentService.updateFields(student!.userId, {
                            'notifications': value
                          });

                          if (!success) {
                            Get.snackbar(
                              appLocalizations.error,
                              appLocalizations.errorMessage,
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: primaryBrandColor.withOpacity(0.1),
                              colorText: primaryBrandColor,
                              icon: Icon(Iconsax.info_circle, color: primaryBrandColor),
                            );
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    required Widget trailing,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: primaryBrandColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: primaryBrandColor, size: 22),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      trailing: trailing,
    );
  }
}
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

import '../../../controllers/auth.dart';
import '../../../controllers/instructor/instructor.dart';
import '../../../l10n/app_localizations.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/helpers/helper_functions.dart';

class AppPreferencesPage extends StatefulWidget {
  const AppPreferencesPage({super.key});

  @override
  State<AppPreferencesPage> createState() => _AppPreferencesPageState();
}

class _AppPreferencesPageState extends State<AppPreferencesPage> {
  final Color primaryBrandColor = const Color(0xFFDF1E42);

  void showLanguageDialog(BuildContext context, AppLocalizations appLocalizations, AuthService authService) {
    final locale = appLocalizations.localeName;
    String tempSelection = locale;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(appLocalizations.changeLanguage, style: const TextStyle(fontWeight: FontWeight.bold)),
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
              const Divider(height: 1),
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
            child: Text(appLocalizations.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primaryBrandColor),
            onPressed: () {
              Navigator.pop(ctx);
              authService.applyLocale(tempSelection);
            },
            child: Text(appLocalizations.ok, style: const TextStyle(color: Colors.white)),
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
    final instructorService = Provider.of<InstructorService>(context);
    final instructor = instructorService.instructor;
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
            /// --- GROUPED PREFERENCES CARD ---
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
                  /// Language Tile
                  _buildPreferenceTile(
                    icon: Iconsax.global,
                    title: appLocalizations.language,
                    subtitle: appLocalizations.languageSub,
                    onTap: () => showLanguageDialog(context, appLocalizations, authService),
                    trailing: const Icon(Iconsax.arrow_right_3, size: 18, color: Colors.grey),
                  ),

                  const Divider(indent: 50, endIndent: 20, height: 1),

                  /// Notifications Tile
                  _buildPreferenceTile(
                    icon: Iconsax.notification,
                    title: appLocalizations.notifications,
                    subtitle: appLocalizations.notificationsSub,
                    onTap: null, // Switch handles the tap
                    trailing: Transform.scale(
                      scale: 0.8,
                      child: Switch(
                        activeColor: primaryBrandColor,
                        value: instructor?.notifications ?? false,
                        onChanged: (value) async {
                          final success = await instructorService.updateFields(instructor!.userId, {
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

  Widget _buildPreferenceTile({
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
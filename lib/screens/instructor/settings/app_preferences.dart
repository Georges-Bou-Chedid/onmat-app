import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

import '../../../controllers/auth.dart';
import '../../../controllers/instructor.dart';
import '../../../l10n/app_localizations.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/widgets/settings_menu_tile.dart';

class AppPreferencesPage extends StatefulWidget {
  const AppPreferencesPage({super.key});

  @override
  State<AppPreferencesPage> createState() => _AppPreferencesPageState();
}
class _AppPreferencesPageState extends State<AppPreferencesPage> {

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();
    final InstructorService instructorService = Provider.of<InstructorService>(context);
    final instructor = instructorService.instructor;
    final appLocalizations = AppLocalizations.of(context)!;

    void showLanguageDialog(BuildContext context) {
      final locale = appLocalizations.localeName;
      String tempSelection = locale;

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(appLocalizations.changeLanguage),
          content: StatefulBuilder(
            builder: (ctx, setState) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<String>(
                  title: Row(
                    children: [
                      Image.asset('assets/images/english.png', width: TSizes.iconMd, height: TSizes.iconMd), // Replace with your flag image
                      const SizedBox(width: TSizes.md),
                      Text(
                        'English',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  value: 'en',
                  groupValue: tempSelection,
                  onChanged: (val) => setState(() => tempSelection = val!),
                ),
                RadioListTile<String>(
                  title: Row(
                    children: [
                      Image.asset('assets/images/arabic.png', width: TSizes.iconMd, height: TSizes.iconMd), // Replace with your flag image
                      const SizedBox(width: TSizes.md),
                      Text(
                        'العربية',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  value: 'ar',
                  groupValue: tempSelection,
                  onChanged: (val) => setState(() => tempSelection = val!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),       // cancel
              child: Text(appLocalizations.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                authService.applyLocale(tempSelection);
              },
              child: Text(appLocalizations.ok),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(appLocalizations.appPreferences),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: TSizes.spaceBtwItems),
        children: [
          /// Language tile
          TSettingsMenuTile(
              icon: Iconsax.global,
              title: appLocalizations.language,
              subTitle: appLocalizations.languageSub,
              onTap: () => showLanguageDialog(context),
          ),

          /// Notifications tile
          TSettingsMenuTile(
            icon: Iconsax.notification,
            title: appLocalizations.notifications,
            subTitle: appLocalizations.notificationsSub,
            trailing: Transform.scale(
              scale: 0.8,                       // 1.0 = default size → lower = smaller
              child: Switch(
                value: instructor!.notifications ?? false,
                onChanged: (value) async {
                  final success = await instructorService.updateFields(instructor.userId, {
                    'notifications': value
                  });

                  if (! success) {
                    Get.snackbar(
                      appLocalizations.error,
                      appLocalizations.errorMessage,
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:get/get.dart';
import 'package:onmat/controllers/auth.dart';
import 'package:onmat/screens/instructor/settings/account_security.dart';
import 'package:onmat/screens/instructor/settings/support_legal.dart';
import 'package:onmat/screens/instructor/settings/wallet_screen.dart';
import 'package:onmat/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:onmat/utils/helpers/helper_functions.dart';
import 'package:provider/provider.dart';

import '../../../controllers/instructor/instructor.dart';
import '../../../controllers/notification_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../../utils/widgets/circular_image.dart';
import '../../splash.dart';
import 'app_preferences.dart';
import 'edit_profile.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // BRAND COLOR
  final Color primaryBrandColor = const Color(0xFFDF1E42);

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();
    final InstructorService instructorService = Provider.of<InstructorService>(context, listen: true);
    final instructor = instructorService.instructor;
    final appLocalizations = AppLocalizations.of(context)!;
    final dark = THelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: dark ? Colors.black : Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true, // This is the professional choice here
        title: Text(
            appLocalizations.accountSettings,
            style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold)
        ),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left_2), // Modern thin icon
          onPressed: () => Get.back(),
          color: dark ? Colors.white : Colors.black,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: TSizes.spaceBtwSections),

            /// --- CENTERED PROFILE HEADER ---
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
                        image: (instructor?.profilePicture != null && instructor!.profilePicture!.isNotEmpty)
                            ? instructor.profilePicture!
                            : "assets/images/settings/user.png",
                        width: 100,
                        height: 100,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Get.to(() => const EditProfilePage(), transition: Transition.downToUp),
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
                  instructor != null ? "${instructor.firstName} ${instructor.lastName}" : 'User Name',
                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  instructor?.email ?? 'email@example.com',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.grey),
                ),
              ],
            ),

            const SizedBox(height: TSizes.spaceBtwSections),

            /// --- SETTINGS GROUPS ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: TSizes.defaultSpace),
              child: Column(
                children: [
                  _buildSettingsGroup(
                    context,
                    dark,
                    [
                      _buildMenuTile(
                        icon: Iconsax.wallet_check,
                        title: appLocalizations.myWallet,
                        subtitle: (instructor?.outstandingBalance ?? 0) > 0
                            ? "Outstanding: \$${instructor!.outstandingBalance.toStringAsFixed(2)}"
                            : "Balance: \$0.00",
                        onTap: () => Get.to(() => const WalletScreen(), transition: Transition.rightToLeft),
                      ),
                      _buildMenuTile(
                        icon: Iconsax.setting_2,
                        title: appLocalizations.appPreferences,
                        subtitle: appLocalizations.appPreferencesSub,
                        onTap: () => Get.to(() => const AppPreferencesPage(), transition: Transition.rightToLeft),
                      ),
                      _buildMenuTile(
                        icon: Iconsax.security,
                        title: appLocalizations.accountAndSecurity,
                        subtitle: appLocalizations.accountAndSecuritySub,
                        onTap: () => Get.to(() => const AccountSecurityPage(), transition: Transition.rightToLeft),
                      ),
                      _buildMenuTile(
                        icon: Iconsax.support,
                        title: appLocalizations.supportAndLegal,
                        subtitle: appLocalizations.supportAndLegalSub,
                        onTap: () => Get.to(() => const SupportLegalPage(), transition: Transition.rightToLeft),
                      ),
                    ],
                  ),

                  const SizedBox(height: TSizes.spaceBtwSections),

                  /// --- LOGOUT BUTTON (MODERN OUTLINED) ---
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

  /// Helper to wrap tiles in a professional container
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

  /// Custom Menu Tile for a cleaner look
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

  /// Standard Logout Logic
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
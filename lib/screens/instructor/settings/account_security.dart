import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../controllers/auth.dart';
import '../../../l10n/app_localizations.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/helpers/helper_functions.dart';
import '../../authentication/password_configuration/forgot_password.dart';
import '../../splash.dart';

class AccountSecurityPage extends StatefulWidget {
  const AccountSecurityPage({super.key});

  @override
  State<AccountSecurityPage> createState() => _AccountSecurityPageState();
}

class _AccountSecurityPageState extends State<AccountSecurityPage> {
  final Color primaryBrandColor = const Color(0xFFDF1E42);

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();
    final googleUser = authService.isGoogleUser();
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
          appLocalizations.accountAndSecurity,
          style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          children: [
            /// --- SECURITY OPTIONS CARD ---
            Container(
              decoration: BoxDecoration(
                color: dark ? Colors.grey[900] : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: Column(
                children: [
                  /// Change Password
                  _buildSecurityTile(
                    icon: Iconsax.key,
                    title: appLocalizations.changePassword,
                    subtitle: appLocalizations.changePasswordSub,
                    onTap: googleUser ? null : () => Get.to(() => const ForgotPasswordScreen()),
                    trailing: googleUser
                        ? const Icon(Iconsax.lock, color: Colors.grey, size: 18)
                        : const Icon(Iconsax.arrow_right_3, size: 18, color: Colors.grey),
                  ),

                  const Divider(indent: 50, endIndent: 20, height: 1),

                  /// Delete Account (Dangerous Action)
                  _buildSecurityTile(
                    icon: Iconsax.user_remove,
                    title: appLocalizations.deleteAccount,
                    subtitle: appLocalizations.deleteAccountSub,
                    iconColor: primaryBrandColor,
                    onTap: () => _showDeleteAccountDialog(context, appLocalizations, authService),
                    trailing: const Icon(Iconsax.arrow_right_3, size: 18, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Refined Security Tile
  Widget _buildSecurityTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
    required Widget trailing,
    Color? iconColor,
  }) {
    final color = iconColor ?? const Color(0xFFDF1E42);
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      trailing: trailing,
    );
  }

  /// Professional Delete Dialog
  void _showDeleteAccountDialog(BuildContext context, AppLocalizations l10n, AuthService auth) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide.none, // Removes the theme border
        ),
        title: Text(l10n.deleteAccount, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(l10n.deleteAccountText),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primaryBrandColor),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.delete, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ).then((confirmed) async {
      if (confirmed == true) {
        final result = await auth.deleteAccount();

        if (result.success) {
          await auth.signOut();
          Get.offAll(() => const SplashScreen());
        } else {
          final errorCode = result.errorMessage;
          final message = switch (errorCode) {
            'user-not-found' => l10n.deleteUserNotFound,
            'requires-recent-login' => l10n.requiresRecentLogin,
            _ => l10n.errorMessage,
          };

          Get.snackbar(
            l10n.error,
            message,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: primaryBrandColor.withOpacity(0.1),
            colorText: primaryBrandColor,
            icon: Icon(Iconsax.info_circle, color: primaryBrandColor),
            margin: const EdgeInsets.all(15),
          );
        }
      }
    });
  }
}
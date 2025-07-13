import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../controllers/auth.dart';
import '../../../l10n/app_localizations.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/widgets/settings_menu_tile.dart';
import '../../authentication/password_configuration/forgot_password.dart';
import '../../splash.dart';

class AccountSecurityPage extends StatefulWidget {
  const AccountSecurityPage({super.key});

  @override
  State<AccountSecurityPage> createState() => _AccountSecurityPageState();
}
class _AccountSecurityPageState extends State<AccountSecurityPage> {

  @override
  Widget build(BuildContext context) {
    final AuthService _authService = AuthService();
    final googleUser = _authService.isGoogleUser();
    final appLocalizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(appLocalizations.accountAndSecurity),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: TSizes.spaceBtwItems),
        children: [
          /// Change Password tile
          TSettingsMenuTile(
            icon: Iconsax.key,
            title: appLocalizations.changePassword,
            subTitle: appLocalizations.changePasswordSub,
            onTap: googleUser ? null : () => Get.to(() => ForgotPasswordScreen()),
            trailing: googleUser
                ? const Icon(Iconsax.lock, color: Colors.grey)
                : null,
          ),

          /// Delete Account tile
          TSettingsMenuTile(
            icon: Iconsax.user_remove,
            title: appLocalizations.deleteAccount,
            subTitle: appLocalizations.deleteAccountSub,
            onTap: () async {
              await showDialog(
              context: context,
              barrierDismissible: true,
              builder: (context) => AlertDialog(
                title: Text(appLocalizations.deleteAccount),
                content: Text(appLocalizations.deleteAccountText),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(appLocalizations.cancel),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text(appLocalizations.delete),
                  ),
                ],
              ),
              ).then((confirmed) async {
                if (confirmed == true) {
                  final result = await _authService.deleteAccount();

                  if (result.success) {
                    await _authService.signOut();
                    Get.offAll(() => const SplashScreen());
                  } else {
                    if (! mounted) return;
                    final errorCode = result.errorMessage;

                    final message = switch (errorCode) {
                      'user-not-found' => appLocalizations.deleteUserNotFound,
                      'requires-recent-login' => appLocalizations.requiresRecentLogin,
                      _ => appLocalizations.errorMessage,
                    };

                    Get.snackbar(
                      "",
                      "",
                      snackPosition: SnackPosition.BOTTOM,
                      titleText: Text(
                        appLocalizations.error,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      messageText: Text(
                        message,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    );
                  }
                }
              });
            }
          ),
        ],
      ),
    );
  }
}

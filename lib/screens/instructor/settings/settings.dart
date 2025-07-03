import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:onmat/controllers/auth.dart';
import 'package:onmat/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:iconsax/iconsax.dart';
import 'package:onmat/utils/widgets/primary_header_container.dart';
import 'package:onmat/utils/widgets/settings_menu_tile.dart';
import 'package:provider/provider.dart';

import '../../../controllers/user.dart';
import '../../../utils/widgets/circular_image.dart';
import '../../../utils/widgets/section_header.dart';
import '../../splash.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late AppLocalizations appLocalizations;

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();
    final UserAccountService userAccountService = Provider.of<UserAccountService>(context);
    final userAccount = userAccountService.userAccount;
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
                      // alignment: Alignment.topCenter,
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
                        userAccount != null
                          ? "${userAccount.firstName} ${userAccount.lastName}"
                          : '',
                        style: Theme.of(context).textTheme.headlineSmall!.apply(color: Colors.white)
                      ),
                      subtitle: Text(
                        userAccount!.email ?? '',
                        style: Theme.of(context).textTheme.bodyMedium!.apply(color: Colors.white)
                      ),
                      trailing: IconButton(
                        onPressed: (){},
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
                    TSectionHeading(title: "Account Settings", showActionButton: false),
                    SizedBox(height: TSizes.spaceBtwItems),

                    TSettingsMenuTile(
                      icon: Iconsax.wallet_check,
                      title: "My Wallet",
                      subTitle: "Outstanding: \$135.00",
                      onTap: () {

                      },
                    ),
                    TSettingsMenuTile(
                      icon: Iconsax.setting_2,
                      title: "App Preferences",
                      subTitle: "Language and Notifications",
                      onTap: () {

                      },
                    ),
                    TSettingsMenuTile(
                      icon: Iconsax.security,
                      title: "Account & Security",
                      subTitle: "Manage password and account access",
                      onTap: () {

                      },
                    ),
                    TSettingsMenuTile(
                      icon: Iconsax.support,
                      title: "Support & Legal",
                      subTitle: "Help, terms, and privacy",
                      onTap: () {

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
                                title: const Text('Confirm Logout'),
                                content: const Text('Are you sure you want to log out?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(true),
                                    child: const Text('Logout'),
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
                          child: const Text('Logout')
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

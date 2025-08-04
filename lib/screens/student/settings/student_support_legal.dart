import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../l10n/app_localizations.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/widgets/settings_menu_tile.dart';

class StudentSupportLegalPage extends StatefulWidget {
  const StudentSupportLegalPage({super.key});

  @override
  State<StudentSupportLegalPage> createState() => _StudentSupportLegalPageState();
}
class _StudentSupportLegalPageState extends State<StudentSupportLegalPage> {
  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(appLocalizations.supportAndLegal),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: TSizes.spaceBtwItems),
        children: [
          /// Website tile
          TSettingsMenuTile(
            icon: Iconsax.link,
            title: appLocalizations.website,
            subTitle: appLocalizations.websiteSub,
            onTap: () {

            }
          ),

          /// Privacy Policy tile
          TSettingsMenuTile(
            icon: Iconsax.shield_tick,
            title: appLocalizations.privacyPolicy,
            subTitle: appLocalizations.privacyPolicySub,
            onTap: () {

            }
          ),

          /// Help tile
          TSettingsMenuTile(
              icon: Iconsax.info_circle,
              title: appLocalizations.help,
              subTitle: appLocalizations.helpSub,
              onTap: () {

              }
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../l10n/app_localizations.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/helpers/helper_functions.dart';

class SupportLegalPage extends StatefulWidget {
  const SupportLegalPage({super.key});

  @override
  State<SupportLegalPage> createState() => _SupportLegalPageState();
}

class _SupportLegalPageState extends State<SupportLegalPage> {
  final Color primaryBrandColor = const Color(0xFFDF1E42);

  @override
  Widget build(BuildContext context) {
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
          appLocalizations.supportAndLegal,
          style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          children: [
            /// --- GROUPED SUPPORT CARD ---
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
                  /// Website tile
                  _buildLegalTile(
                    icon: Iconsax.link,
                    title: appLocalizations.website,
                    subtitle: appLocalizations.websiteSub,
                    onTap: () {
                      // Use url_launcher to open your website
                    },
                  ),

                  const Divider(indent: 50, endIndent: 20, height: 1),

                  /// Privacy Policy tile
                  _buildLegalTile(
                    icon: Iconsax.shield_tick,
                    title: appLocalizations.privacyPolicy,
                    subtitle: appLocalizations.privacyPolicySub,
                    onTap: () {
                      // Navigate to a WebView or external URL
                    },
                  ),

                  const Divider(indent: 50, endIndent: 20, height: 1),

                  /// Help tile
                  _buildLegalTile(
                    icon: Iconsax.info_circle,
                    title: appLocalizations.help,
                    subtitle: appLocalizations.helpSub,
                    onTap: () {
                      // Navigate to your FAQ or Contact Us page
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Reusable Tile Helper
  Widget _buildLegalTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
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
      title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)
      ),
      subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: Colors.grey)
      ),
      trailing: const Icon(Iconsax.export_1, size: 18, color: Colors.grey), // "Export" icon suggests opening external links
    );
  }
}
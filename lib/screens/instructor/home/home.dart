import 'package:onmat/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({super.key});

  @override
  _HomePageScreenState createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late AppLocalizations appLocalizations;

  @override
  Widget build(BuildContext context) {
    appLocalizations = AppLocalizations.of(context)!;

    return Scaffold(
        extendBodyBehindAppBar: true,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          actions: [
            Padding(
              padding: EdgeInsets.only(
                left: TSizes.borderRadiusMd,
                right: TSizes.borderRadiusMd,
              ),
              child: PopupMenuButton(
                icon: Icon(Iconsax.language_circle, size: TSizes.iconMd),
                itemBuilder: (BuildContext context) => <PopupMenuEntry<Locale>>[
                  PopupMenuItem<Locale>(
                    value: const Locale('en'),
                    child: Row(
                      children: [
                        Image.asset('assets/images/english.png', width: TSizes.iconMd, height: TSizes.iconMd), // Replace with your flag image
                        const SizedBox(width: TSizes.md),
                        Text(
                          appLocalizations.english,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem<Locale>(
                    value: const Locale('ar'),
                    child: Row(
                      children: [
                        Image.asset('assets/images/arabic.png', width: TSizes.iconMd, height: TSizes.iconMd), // Replace with your flag image
                        const SizedBox(width: TSizes.md),
                        Text(
                          appLocalizations.arabic,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
                onSelected: (Locale locale) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Get.updateLocale(locale);
                  });
                },
              ),
            ),
          ],
        ),
        body: Stack()
    );
  }
}

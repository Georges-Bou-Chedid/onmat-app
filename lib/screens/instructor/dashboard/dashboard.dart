import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../l10n/app_localizations.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/widgets/primary_header_container.dart';
import '../settings/edit_profile.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late AppLocalizations appLocalizations;

  @override
  Widget build(BuildContext context) {
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

                    /// Classes Card
                    ListTile(
                      title: Text(
                          "My Classes",
                          style: Theme.of(context).textTheme.headlineSmall!.apply(color: Colors.white)
                      ),
                      trailing: IconButton(
                          onPressed: (){
                            Get.to(
                              () => const EditProfilePage(),
                              transition: Transition.downToUp,        // comes from bottom, exits at top
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,               // optional: smoother easing
                            );
                          },
                          icon: const Icon(Iconsax.additem, color: Colors.white)
                      ),
                    ),
                    const SizedBox(height: TSizes.spaceBtwSections)
                  ],
                ),
              ),

              /// Body
            ],
          ),
        )
    );
  }
}

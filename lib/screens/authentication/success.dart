import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/constants/sizes.dart';
import '../../utils/helpers/helper_functions.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../splash.dart';

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    AppLocalizations appLocalizations = AppLocalizations.of(context)!;

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            top: 0,
            left: TSizes.defaultSpace,
            bottom: TSizes.defaultSpace,
            right: TSizes.defaultSpace,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ///Image
                  Image.asset(
                    'assets/images/logo-red.png',
                    width: THelperFunctions.screenWidth(context) * 0.3,
                    alignment: Alignment.center,
                  ),
                  const SizedBox(height: TSizes.spaceBtwSections),

                  /// Title & Subtitle
                  Text(
                    appLocalizations.yourAccountCreatedTitle,
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: TSizes.spaceBtwItems),
                  Text(
                    appLocalizations.yourAccountCreatedSubTitle,
                    style: Theme.of(context).textTheme.labelMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: TSizes.spaceBtwSections),

                  /// Buttons
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      child: Text(
                        appLocalizations.tContinue,
                        style: const TextStyle(
                            fontFamily: "Inter",
                            fontSize: 14,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                      onPressed: () => Get.offAll(() => const SplashScreen())
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      )
    );
  }
}
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:onmat/screens/authentication/onboarding/signup.dart';
import '../../../l10n/app_localizations.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/helpers/helper_functions.dart';
import '../../splash.dart';

class SelectRoleScreen extends StatelessWidget {
  const SelectRoleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    AppLocalizations appLocalizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            top: 0,
            left: TSizes.defaultSpace,
            bottom: TSizes.defaultSpace,
            right: TSizes.defaultSpace,
          ),
          child: IntrinsicHeight(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ///Image
                Image.asset(
                  'assets/images/logo-red.png',
                  width: THelperFunctions.screenWidth(context) * 0.28,
                  alignment: Alignment.center,
                ),
                const SizedBox(height: TSizes.spaceBtwSections),

                /// Subtitle
                Text(
                  appLocalizations.chooseRoleToContinue,
                  style: Theme.of(context).textTheme.labelMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: TSizes.spaceBtwSections),

                /// Buttons
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    child: Text(
                      appLocalizations.joinAsInstructor,
                      style: const TextStyle(
                          fontFamily: "Inter",
                          fontSize: 14,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                    onPressed: () => Get.to(() => const SignupScreen(selectedRole: 'instructor'))
                  ),
                ),
                const SizedBox(height: TSizes.spaceBtwItems),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                      child: Text(
                        appLocalizations.joinAsStudent,
                        style: const TextStyle(
                            fontFamily: "Inter",
                            fontSize: 14,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                      onPressed: () => Get.to(() => const SignupScreen(selectedRole: 'student'))
                  )
                ),
              ],
            ),
          ),
        ),
      )
    );
  }
}
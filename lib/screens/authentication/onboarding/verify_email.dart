import 'package:onmat/screens/authentication/onboarding/success.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../l10n/app_localizations.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/helpers/helper_functions.dart';
import '../login/login.dart';

class VerifyEmailScreen extends StatefulWidget {
  final String email;

  const VerifyEmailScreen({super.key, required this.email});

  @override
  _VerifyEmailScreenState createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  late AppLocalizations appLocalizations;
  bool _isContinueLoading = false;
  bool _isResendLoading = false;

  void verify() async {
    setState(() => _isContinueLoading = true);

    try {
      await FirebaseAuth.instance.currentUser?.reload();
      final user = FirebaseAuth.instance.currentUser;

      if (user != null && user.emailVerified) {
        Get.to(() => SuccessScreen());
      } else {
        Get.snackbar(
          appLocalizations.emailNotVerifiedTitle,
          appLocalizations.emailNotVerifiedMessage,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        appLocalizations.error,
        appLocalizations.errorMessage,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      setState(() => _isContinueLoading = false);
    }
  }

  void resendEmail() async {
    setState(() => _isResendLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      await user?.sendEmailVerification();
      Get.snackbar(
        appLocalizations.verificationEmailSent,
        appLocalizations.verificationEmailSentMessage,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        appLocalizations.error,
        appLocalizations.errorMessage,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      setState(() => _isResendLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    appLocalizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(
              left: TSizes.borderRadiusMd,
              right: TSizes.borderRadiusMd,
            ),
            child: IconButton(
              icon: const Icon(CupertinoIcons.clear),
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();  // Log out the user
                  Get.offAll(() => const LoginScreen());  // Navigate to login screen, removing all previous routes
                }
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            top: 0,
            left: TSizes.defaultSpace,
            bottom: TSizes.defaultSpace,
            right: TSizes.defaultSpace,
          ),
          child: SizedBox(
            height: MediaQuery.of(context).size.height -
                kToolbarHeight -
                MediaQuery.of(context).padding.top,
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
            
                /// Title & Subtitle
                Text(
                  appLocalizations.confirmEmail,
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: TSizes.spaceBtwItems),
                Text(
                  widget.email,
                  style: Theme.of(context).textTheme.labelLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: TSizes.spaceBtwItems),
                Text(
                  appLocalizations.confirmEmailSubtitle,
                  style: Theme.of(context).textTheme.labelMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: TSizes.spaceBtwSections),
            
                /// Buttons
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isContinueLoading
                      ? null
                      : () async {
                        verify();
                      },
                    child: _isContinueLoading
                        ? const SizedBox(
                          height: TSizes.md,
                          width: TSizes.md,
                          child: CircularProgressIndicator(),
                        )
                        : Text(
                            appLocalizations.tContinue,
                            style: const TextStyle(
                                fontFamily: "Inter",
                                fontSize: 14,
                                fontWeight: FontWeight.bold
                            ),
                          )
                  ),
                ),
                const SizedBox(height: TSizes.spaceBtwItems),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: _isResendLoading
                        ? null
                        : () async {
                          resendEmail();
                        },
                    child: _isResendLoading
                        ? const SizedBox(
                          height: TSizes.md,
                          width: TSizes.md,
                          child: CircularProgressIndicator(),
                        ) : Text(
                          appLocalizations.resendEmail,
                          style: const TextStyle(
                              fontFamily: "Inter",
                              fontSize: 14,
                              fontWeight: FontWeight.bold
                          ),
                        )
                  ),
                ),
              ],
            ),
          ),
        ),
      )
    );
  }
}
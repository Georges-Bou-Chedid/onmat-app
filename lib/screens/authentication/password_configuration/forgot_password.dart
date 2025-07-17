import 'package:iconsax/iconsax.dart';
import 'package:onmat/screens/authentication/password_configuration/reset_password.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../l10n/app_localizations.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/helpers/helper_functions.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailEditingController = TextEditingController();
  late AppLocalizations appLocalizations;
  bool _isContinueLoading = false;

  void sendPasswordResetLink() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isContinueLoading = true);

      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(
            email: _emailEditingController.text.trim()
        );
        Get.to(() => ResetPasswordScreen());
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
              onPressed: () => Get.back()
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
            child: Form(
              key: _formKey,
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
                    appLocalizations.forgotPassword,
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: TSizes.spaceBtwItems),
                  Text(
                    appLocalizations.forgotPasswordSubtitle,
                    style: Theme.of(context).textTheme.labelMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: TSizes.spaceBtwSections),

                  TextFormField(
                    controller: _emailEditingController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return appLocalizations.enterYourEmail;
                      }

                      bool emailValid = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value);
                      if (! emailValid) {
                        return appLocalizations.emailValidation;
                      }

                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: appLocalizations.email,
                      prefixIcon: Icon(Iconsax.direct_right),
                    ),
                  ),
                  const SizedBox(height: TSizes.spaceBtwItems),

                  /// Buttons
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isContinueLoading
                        ? null
                        : () async {
                          sendPasswordResetLink();
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
                ],
              ),
            ),
          ),
        ),
      )
    );
  }
}
import 'package:onmat/screens/authentication/onboarding/signup.dart';
import 'package:onmat/screens/authentication/onboarding/verify_email.dart';
import 'package:onmat/screens/splash.dart';
import 'package:onmat/utils/constants/sizes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../common/styles/spacing_styles.dart';
import '../../../controllers/auth.dart';
import '../../../l10n/app_localizations.dart';
import '../password_configuration/forgot_password.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailEditingController = TextEditingController();
  final TextEditingController _passwordEditingController = TextEditingController();
  late AppLocalizations appLocalizations;
  bool isPasswordVisible = false;
  bool rememberMe = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    appLocalizations = AppLocalizations.of(context)!;

    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          actions: [
            Padding(
              padding: const EdgeInsets.only(
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
                          'English',
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
                          'العربية',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
                onSelected: (Locale locale) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _authService.applyLocale(locale.languageCode);
                  });
                },
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: TSpacingStyle.paddingWithAppBarHeight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: TSizes.appBarHeight),
                /// Language, Logo, Title & Sub-Title
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset('assets/images/logo-red.png', width: 80, height: 130),
                    Text(appLocalizations.loginTitle, style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: TSizes.sm),
                    Text(appLocalizations.loginSubtitle, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),

                /// Form
                Form(
                    key: _formKey,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: TSizes.spaceBtwSections),
                      child: Column(
                        children: [
                          ///Email
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
                          const SizedBox(height: TSizes.spaceBtwInputFields),

                          /// Password
                          TextFormField(
                            controller: _passwordEditingController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return appLocalizations.enterYourPassword;
                              }

                              if (value.length < 6) {
                                return appLocalizations.passwordValidation;
                              }
                              return null;
                            },
                            obscureText: ! isPasswordVisible,
                            decoration: InputDecoration(
                                labelText: appLocalizations.password,
                                prefixIcon: const Icon(Iconsax.password_check),
                                suffixIcon: IconButton(
                                  icon: Icon(isPasswordVisible
                                      ? Iconsax.eye
                                      : Iconsax.eye_slash),
                                  onPressed: () {
                                    setState(() {
                                      isPasswordVisible = ! isPasswordVisible;
                                    });
                                  },
                                )),
                          ),
                          const SizedBox(height: TSizes.spaceBtwInputFields / 2),

                          /// Remember Me & Forget Password
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              /// Remember Me
                              Row(
                                children: [
                                  Checkbox(
                                      value: rememberMe,
                                      onChanged: (value) {
                                        if (value == null) {
                                          return;
                                        }
                                        setState(() {
                                          rememberMe = value;
                                        });
                                      }
                                  ),
                                  Text(
                                      appLocalizations.rememberMe,
                                      style: Theme.of(context).textTheme.labelLarge
                                  )
                                ],
                              ),

                              /// Forget Password
                              TextButton(
                                  onPressed: () {
                                    Get.to(() => ForgotPasswordScreen());
                                  },
                                  child: Text(
                                    "${appLocalizations.forgotPassword}?",
                                    style: const TextStyle(
                                      fontFamily: "Inter",
                                      fontSize: 12,
                                    ),
                                  )
                              ),
                            ],
                          ),
                          const SizedBox(height: TSizes.spaceBtwSections),

                          /// Sign In Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading
                                  ? null
                                  : () async {
                                if (_formKey.currentState?.validate() ?? false) {
                                  setState(() {
                                    _isLoading = true;
                                  });

                                  final result = await _authService.signInByEmail(
                                      _emailEditingController.text.trim(),
                                      _passwordEditingController.text.trim()
                                  );

                                  setState(() {
                                    _isLoading = false;
                                  });

                                  if (result.success) {
                                    await FirebaseAuth.instance.currentUser?.reload();
                                    final user = FirebaseAuth.instance.currentUser;

                                    if (! user!.emailVerified) {
                                      Get.to(() => VerifyEmailScreen(email: _emailEditingController.text.trim()));
                                    } else {
                                      Get.offAll(() => const SplashScreen());
                                    }
                                  } else {
                                    if (! mounted) return;
                                    final errorCode = result.errorMessage;

                                    final message = switch (errorCode) {
                                      'invalid-credential' => appLocalizations.userNotFound,
                                      'user-disabled' => appLocalizations.userDisabled,
                                      _ => appLocalizations.signInFailedMessage,
                                    };

                                    Get.snackbar(
                                      "",
                                      "",
                                      snackPosition: SnackPosition.BOTTOM,
                                      titleText: Text(
                                        appLocalizations.signInFailedTitle,
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                                      ),
                                      messageText: Text(
                                        message,
                                        style: Theme.of(context).textTheme.bodyMedium,
                                      ),
                                    );
                                  }
                                }
                              },
                              child: _isLoading
                                  ? const SizedBox(
                                height: TSizes.md,
                                width: TSizes.md,
                                child: CircularProgressIndicator(),
                              ) : Text(
                                appLocalizations.signIn,
                                style: const TextStyle(
                                    fontFamily: "Inter",
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: TSizes.spaceBtwItems),

                          /// Create Account Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor: WidgetStateProperty.all(Colors.grey.shade400),
                                foregroundColor: WidgetStateProperty.all(const Color(0xFF1E1E1E)),
                              ),
                              child: Text(
                                appLocalizations.createAccount,
                                style: const TextStyle(
                                    fontFamily: "Inter",
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                              onPressed: () => Get.to(() => SignupScreen()),
                            ),
                          ),
                        ],
                      ),
                    )
                ),

                /// Divider
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(child: Divider(thickness: 0.5, indent: 60, endIndent: 5)),
                    Text(
                        appLocalizations.orSignInWith,
                        style: Theme.of(context).textTheme.labelMedium
                    ),
                    Flexible(child: Divider(thickness: 0.5, indent: 5, endIndent: 60))
                  ],
                ),
                const SizedBox(height: TSizes.spaceBtwSections),

                /// Footer
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey.shade500,
                          ),
                          borderRadius: BorderRadius.circular(100)
                      ),
                      child: IconButton(
                          onPressed: () async {
                            final result = await _authService.signInWithGoogleIfExists();

                            if (result.success) {
                              Get.offAll(() => const SplashScreen());
                            } else {
                              if (! mounted) return;
                              final errorCode = result.errorMessage;

                              final message = switch (errorCode) {
                                'google-cancelled' => appLocalizations.googleCancelled,
                                'user-not-found' => appLocalizations.googleUserNotFound,
                                _ => appLocalizations.signInFailedMessage,
                              };

                              Get.snackbar(
                                "",
                                "",
                                snackPosition: SnackPosition.BOTTOM,
                                titleText: Text(
                                  appLocalizations.signInFailedTitle,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                messageText: Text(
                                  message,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              );
                            }
                          },
                          icon: const Image(
                              width: TSizes.iconMd,
                              height: TSizes.iconMd,
                              image: AssetImage('assets/images/google.png')
                          )
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
    );
  }
}

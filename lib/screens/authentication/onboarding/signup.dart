import 'package:flutter/services.dart';
import 'package:onmat/controllers/user.dart';
import 'package:onmat/screens/authentication/onboarding/verify_email.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import '../../../../../controllers/auth.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../common/styles/spacing_styles.dart';
import '../../../models/UserAccount.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/helpers/helper_functions.dart';
import '../../splash.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  _SignUpScreenScreenState createState() => _SignUpScreenScreenState();
}

class _SignUpScreenScreenState extends State<SignupScreen> {
  final AuthService _authService = AuthService();
  final UserAccountService userAccountService = UserAccountService();
  final GlobalKey<FormState> signUpKey = GlobalKey<FormState>();
  final TextEditingController _firstNameEditingController = TextEditingController();
  final TextEditingController _lastNameEditingController = TextEditingController();
  final TextEditingController _usernameEditingController = TextEditingController();
  final TextEditingController _dateOfBirthEditingController = TextEditingController();
  final TextEditingController _weightEditingController = TextEditingController();
  final TextEditingController _emailEditingController = TextEditingController();
  final TextEditingController _passwordEditingController = TextEditingController();
  final TextEditingController _phoneNumberEditingController = TextEditingController();
  late AppLocalizations appLocalizations;
  bool termsAndConditions = false;
  dynamic _selectedRole;
  bool termsError = false;
  bool _isLoading = false;
  bool skipEmailValidation = false;
  bool skipPasswordValidation = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    appLocalizations = AppLocalizations.of(context)!;
    final dark = THelperFunctions.isDarkMode(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: TSpacingStyle.paddingWithAppBarHeight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: TSizes.appBarHeight * 2),
              /// Title
              Text(
                  appLocalizations.signUp,
                  style: Theme.of(context).textTheme.headlineMedium
              ),
              const SizedBox(height: TSizes.spaceBtwSections),

              /// Form
              Form(
                key: signUpKey,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return appLocalizations.firstNameRequired; // "Please select your role"
                              }
                              return null;
                            },
                            controller: _firstNameEditingController,
                            expands: false,
                            decoration: InputDecoration(
                                labelText: appLocalizations.firstName,
                                prefixIcon: Icon(Iconsax.user)
                            ),
                          ),
                        ),
                        const SizedBox(width: TSizes.spaceBtwInputFields),
                        Expanded(
                          child: TextFormField(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return appLocalizations.lastNameRequired;
                              }
                              return null;
                            },
                            controller: _lastNameEditingController,
                            expands: false,
                            decoration: InputDecoration(
                                labelText: appLocalizations.lastName,
                                prefixIcon: Icon(Iconsax.user)
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: TSizes.spaceBtwInputFields),

                    /// Username
                    TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return appLocalizations.pleaseSelectUsername; // "Please select your role"
                        }
                        return null;
                      },
                      controller: _usernameEditingController,
                      expands: false,
                      decoration: InputDecoration(
                          labelText: appLocalizations.username,
                          prefixIcon: Icon(Iconsax.user_edit)
                      ),
                    ),
                    const SizedBox(height: TSizes.spaceBtwInputFields),

                    TextFormField(
                      controller: _dateOfBirthEditingController,
                      keyboardType: TextInputType.datetime,
                      decoration: InputDecoration(
                        labelText: appLocalizations.dateOfBirth,
                        hintText: 'DD/MM/YYYY',
                        hintStyle: const TextStyle(
                          fontFamily: "Inter",
                          fontSize: 13.5,
                          color: Colors.grey
                        ),
                        prefixIcon: Icon(Iconsax.calendar),
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9/]')),
                        LengthLimitingTextInputFormatter(10),
                        _DateInputFormatter(), // custom formatter to add slashes
                      ],
                      validator: (value) {
                        if (_selectedRole == "student") {
                          if (value == null || value.isEmpty) return appLocalizations.selectDateOfBirth;
                        } else {
                          if (value == null || value.isEmpty) return null;
                        }
                        if (! RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(value)) return appLocalizations.dateOfBirthValidation;
                        return null;
                      },
                    ),
                    const SizedBox(height: TSizes.spaceBtwInputFields),

                    TextFormField(
                      controller: _weightEditingController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: appLocalizations.weight,
                        suffixText: 'kg',
                        prefixIcon: Icon(Iconsax.weight), // Or any icon of your choice
                      ),
                      validator: (value) {
                        if (_selectedRole == "student") {
                          if (value == null || value.isEmpty) return appLocalizations.selectWeight;
                        } else {
                          if (value == null || value.isEmpty) return null;
                        }
                        final weight = double.tryParse(value);
                        if (weight == null || weight <= 0) return appLocalizations.weightValidation;
                        return null;
                      },
                    ),
                    const SizedBox(height: TSizes.spaceBtwInputFields),

                    /// Role Dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedRole,
                      decoration: InputDecoration(
                        labelText: appLocalizations.registerAs, // "Register as"
                        prefixIcon: Icon(Iconsax.user_cirlce_add),
                      ),
                      dropdownColor: Colors.white,
                      borderRadius: BorderRadius.circular(20.0),
                      items: [
                        DropdownMenuItem(value: 'instructor', child: Text(appLocalizations.instructor)), // "Student"
                        DropdownMenuItem(value: 'student', child: Text(appLocalizations.student)),     // "Coach"
                      ],
                      onChanged: (String? value) {
                        setState(() {
                          _selectedRole = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return appLocalizations.pleaseSelectRole; // "Please select your role"
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: TSizes.spaceBtwInputFields),

                    /// Email
                    TextFormField(
                      controller: _emailEditingController,
                      validator: (value) {
                        if (skipEmailValidation) return null;

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
                          prefixIcon: Icon(Iconsax.direct)
                      ),
                    ),
                    const SizedBox(height: TSizes.spaceBtwInputFields),

                    /// Phone Number
                    InternationalPhoneNumberInput(
                      onInputChanged: (PhoneNumber number) {
                        if (number.phoneNumber! == number.dialCode) {
                          _phoneNumberEditingController.text = "";
                        } else {
                          _phoneNumberEditingController.text = number.phoneNumber!;
                        }
                      },
                      locale: AppLocalizations.of(context)!.localeName,
                      selectorConfig: const SelectorConfig(
                        selectorType: PhoneInputSelectorType.DIALOG,
                        useEmoji: true,
                        trailingSpace: false,
                      ),
                      isEnabled: true,
                      ignoreBlank: false,
                      autoValidateMode: AutovalidateMode.disabled,
                      initialValue: PhoneNumber(
                          phoneNumber: _phoneNumberEditingController.text,
                          isoCode: "LB"
                      ),
                      inputDecoration: InputDecoration(
                          labelText: appLocalizations.phoneNumber
                      ),
                      spaceBetweenSelectorAndTextField: 2,
                      formatInput: true,
                      keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                      inputBorder: InputBorder.none,
                      selectorTextStyle: TextStyle(
                        color: dark ? Colors.white : Color(0xFF1E1E1E),
                        fontSize: 16.0,
                      ),
                      cursorColor: Color(0xFF1E1E1E),
                    ),
                    const SizedBox(height: TSizes.spaceBtwInputFields),

                    /// Password
                    TextFormField(
                      controller: _passwordEditingController,
                      validator: (value) {
                        if (skipPasswordValidation) return null;

                        if (value == null || value.isEmpty) {
                          return appLocalizations.enterYourPassword;
                        }

                        if (value.length < 6) {
                          return appLocalizations.passwordValidation;
                        }
                        return null;
                      },
                      obscureText: true,
                      decoration: InputDecoration(
                          labelText: appLocalizations.password,
                          prefixIcon: Icon(Iconsax.password_check),
                          suffixIcon: Icon(Iconsax.eye_slash)
                      ),
                    ),
                    const SizedBox(height: TSizes.spaceBtwSections),

                    /// Terms&Conditions Checkbox
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Checkbox(
                              value: termsAndConditions,
                              onChanged: (value) {
                                setState(() {
                                  termsAndConditions = value ?? false;
                                  termsError = false;
                                });
                              }
                          ),
                        ),
                        const SizedBox(width: TSizes.spaceBtwItems),
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                                children: [
                                  TextSpan(
                                      text: '${appLocalizations.iAgreeTo} ',
                                      style: Theme.of(context).textTheme.bodySmall
                                  ),
                                  TextSpan(
                                      text: appLocalizations.privacyPolicy,
                                      style: Theme.of(context).textTheme.bodyMedium!.apply(
                                          decoration: TextDecoration.underline
                                      )
                                  ),
                                  TextSpan(
                                      text: ' ${appLocalizations.and} ',
                                      style: Theme.of(context).textTheme.bodySmall
                                  ),
                                  TextSpan(
                                      text: appLocalizations.termsOfUse,
                                      style: Theme.of(context).textTheme.bodyMedium!.apply(
                                          decoration: TextDecoration.underline
                                      )
                                  ),
                                ]
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (termsError)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          "Please accept the terms", // e.g., "Please accept the terms."
                          style: TextStyle(color: Color(0xFFB3261E), fontSize: 12),
                        ),
                      ),
                    const SizedBox(height: TSizes.spaceBtwSections),

                    /// Sign Up Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : () async {
                          final isFormValid = signUpKey.currentState!.validate();

                          if (! isFormValid || ! termsAndConditions) {
                            if (! termsAndConditions) {
                              setState(() {
                                termsError = true;
                              });
                            }
                            return;
                          }

                          setState(() {
                            _isLoading = true;
                          });

                          UserAccount userAccount = UserAccount(
                            firstName: _firstNameEditingController.text,
                            lastName: _lastNameEditingController.text,
                            username: _usernameEditingController.text,
                            dob: _dateOfBirthEditingController.text,
                            weight: int.tryParse(_weightEditingController.text),
                            email: _emailEditingController.text,
                            phoneNumber: _phoneNumberEditingController.text,
                            role: _selectedRole,
                            notifications: false
                          );

                          final result = await _authService.signUpByEmail(
                            _emailEditingController.text.trim(),
                            _passwordEditingController.text.trim(),
                            userAccount
                          );

                          setState(() {
                            _isLoading = false;
                          });

                          if (result.success) {
                            Get.to(() => VerifyEmailScreen(email: _emailEditingController.text.trim()));
                          } else {
                            if (! mounted) return;
                            final errorCode = result.errorMessage;

                            final message = switch (errorCode) {
                              'email-already-in-use' => appLocalizations.emailAlreadyInUse,
                              'invalid-email' => appLocalizations.invalidEmail,
                              'weak-password' => appLocalizations.weakPassword,
                              'username-already-taken' => appLocalizations.usernameTaken,
                              _ => appLocalizations.signUpFailedMessage,
                            };

                            Get.snackbar(
                              "",
                              "",
                              snackPosition: SnackPosition.BOTTOM,
                              titleText: Text(
                                appLocalizations.signUpFailedTitle,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              messageText: Text(
                                message,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            );
                          }
                        },
                        child: _isLoading
                            ? const SizedBox(
                          height: TSizes.md,
                          width: TSizes.md,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1E1E1E)),
                          ),
                        )
                            : Text(
                          appLocalizations.createAccount,
                          style: const TextStyle(
                            fontFamily: "Inter",
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: TSizes.spaceBtwSections),

              /// Divider
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(child: Divider(thickness: 0.5, indent: 60, endIndent: 5)),
                  Text(
                      appLocalizations.orSignUpWith,
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
                          setState(() {
                            skipEmailValidation = true;
                            skipPasswordValidation = true;
                          });

                          final isFormValid = signUpKey.currentState!.validate();

                          setState(() {
                            skipEmailValidation = false;
                            skipPasswordValidation = false;
                          });

                          if (! isFormValid || ! termsAndConditions) {
                            if (! termsAndConditions) {
                              setState(() {
                                termsError = true;
                              });
                            }
                            return;
                          }

                          UserAccount userAccount = UserAccount(
                            firstName: _firstNameEditingController.text,
                            lastName: _lastNameEditingController.text,
                            username: _usernameEditingController.text,
                            dob: _dateOfBirthEditingController.text,
                            weight: int.tryParse(_weightEditingController.text),
                            phoneNumber: _phoneNumberEditingController.text,
                            role: _selectedRole,
                            notifications: false
                          );

                          final result = await _authService.signUpWithGoogleAndCreateUser(userAccount);

                          if (result.success) {
                            Get.offAll(() => const SplashScreen());
                          } else {
                            if (! mounted) return;
                            final errorCode = result.errorMessage;

                            final message = switch (errorCode) {
                              'google-cancelled' => appLocalizations.googleCancelled,
                              'user-already-exists' => appLocalizations.googleUserFound,
                              'username-already-taken' => appLocalizations.usernameTaken,
                              _ => appLocalizations.signUpFailedMessage,
                            };

                            Get.snackbar(
                              "",
                              "",
                              snackPosition: SnackPosition.BOTTOM,
                              titleText: Text(
                                appLocalizations.signUpFailedTitle,
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

class _DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text.replaceAll('/', '');
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      if ((i == 1 || i == 3) && i != text.length - 1) {
        buffer.write('/');
      }
    }
    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
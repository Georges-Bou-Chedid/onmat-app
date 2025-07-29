import 'package:flutter/services.dart';
import 'package:onmat/controllers/instructor.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:provider/provider.dart';
import '../../../common/styles/spacing_styles.dart';
import '../../../l10n/app_localizations.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/helpers/helper_functions.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final GlobalKey<FormState> editProfileKey = GlobalKey<FormState>();
  final TextEditingController _firstNameEditingController = TextEditingController();
  final TextEditingController _lastNameEditingController = TextEditingController();
  final TextEditingController _usernameEditingController = TextEditingController();
  final TextEditingController _dateOfBirthEditingController = TextEditingController();
  final TextEditingController _weightEditingController = TextEditingController();
  final TextEditingController _phoneNumberEditingController = TextEditingController();
  late AppLocalizations appLocalizations;
  bool _isLoading = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    final instructor = Provider.of<InstructorService>(context, listen: false).instructor;

    if (instructor != null) {
      _firstNameEditingController.text   = instructor.firstName ?? '';
      _lastNameEditingController.text    = instructor.lastName ?? '';
      _usernameEditingController.text    = instructor.username ?? '';
      _dateOfBirthEditingController.text = instructor.dob ?? '';
      _weightEditingController.text      = instructor.weight?.toString() ?? '';
      _phoneNumberEditingController.text = instructor.phoneNumber ?? '';
    }
    _isInitialized = true;
  }

  @override
  void dispose() {
    _firstNameEditingController.dispose();
    _lastNameEditingController.dispose();
    _usernameEditingController.dispose();
    _dateOfBirthEditingController.dispose();
    _weightEditingController.dispose();
    _phoneNumberEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    appLocalizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(appLocalizations.editProfile),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: TSpacingStyle.paddingWithAppBarHeight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Form
              Form(
                key: editProfileKey,
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
                                return appLocalizations.lastNameRequired; // "Please select your role"
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
                          return appLocalizations.pleaseSelectUsername;
                        }
                        return null;
                      },
                      controller: _usernameEditingController,
                      enabled: false,
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
                    const SizedBox(height: TSizes.spaceBtwSections),

                    /// Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : () async {
                          if (! editProfileKey.currentState!.validate()) return;

                          setState(() => _isLoading = true);

                          final instructorService = context.read<InstructorService>();
                          final instructor = instructorService.instructor;

                          final changes = <String, dynamic>{};

                          void addIfChanged(String key, dynamic newVal, dynamic oldVal) {
                            if (newVal != null && newVal != oldVal) changes[key] = newVal;
                          }

                          addIfChanged('first_name', _firstNameEditingController.text.trim(), instructor?.firstName);
                          addIfChanged('last_name', _lastNameEditingController.text.trim(), instructor?.lastName);
                          addIfChanged('dob', _dateOfBirthEditingController.text.trim(), instructor?.dob);
                          addIfChanged('weight', int.tryParse(_weightEditingController.text), instructor?.weight);
                          addIfChanged('phone_number', _phoneNumberEditingController.text.trim(), instructor?.phoneNumber);

                          // Nothing to update?
                          if (changes.isEmpty) {
                            setState(() => _isLoading = false);
                            return;
                          }

                          // 3. call service
                          final success = await instructorService.updateFields(instructor!.userId, changes);

                          setState(() {
                            _isLoading = false;
                          });

                          if (success) {
                            Get.back();
                            Get.snackbar(
                              appLocalizations.success,
                              appLocalizations.profileUpdated,
                              snackPosition: SnackPosition.BOTTOM
                            );
                          } else {
                            Get.snackbar(
                              appLocalizations.error,
                              appLocalizations.errorMessage,
                              snackPosition: SnackPosition.BOTTOM
                            );
                          }
                        },
                        child: _isLoading
                            ? const SizedBox(
                          height: TSizes.md,
                          width: TSizes.md,
                          child: CircularProgressIndicator(),
                        )
                            : Text(
                          appLocalizations.save,
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
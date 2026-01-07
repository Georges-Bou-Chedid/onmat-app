import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:onmat/controllers/student/student.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/helpers/helper_functions.dart';
import '../../../utils/widgets/circular_image.dart';

class StudentEditProfilePage extends StatefulWidget {
  const StudentEditProfilePage({super.key});

  @override
  _StudentEditProfilePageState createState() => _StudentEditProfilePageState();
}

class _StudentEditProfilePageState extends State<StudentEditProfilePage> {
  final GlobalKey<FormState> editProfileKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _firstNameEditingController = TextEditingController();
  final TextEditingController _lastNameEditingController = TextEditingController();
  final TextEditingController _genderEditingController = TextEditingController();
  final TextEditingController _usernameEditingController = TextEditingController();
  final TextEditingController _dateOfBirthEditingController = TextEditingController();
  final TextEditingController _weightEditingController = TextEditingController();
  final TextEditingController _heightEditingController = TextEditingController();
  final TextEditingController _phoneNumberEditingController = TextEditingController();

  final Color primaryBrandColor = const Color(0xFFDF1E42);
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final student = Provider.of<StudentService>(context, listen: false).student;

    if (student != null) {
      _firstNameEditingController.text   = student.firstName ?? '';
      _lastNameEditingController.text    = student.lastName ?? '';
      _genderEditingController.text      = student.gender ?? '';
      _usernameEditingController.text    = student.username ?? '';
      _dateOfBirthEditingController.text = student.dob ?? '';
      _weightEditingController.text      = student.weight?.toString() ?? '';
      _heightEditingController.text      = student.height?.toString() ?? '';
      _phoneNumberEditingController.text = student.phoneNumber ?? '';
    }
  }

  @override
  void dispose() {
    _firstNameEditingController.dispose();
    _lastNameEditingController.dispose();
    _genderEditingController.dispose();
    _usernameEditingController.dispose();
    _dateOfBirthEditingController.dispose();
    _weightEditingController.dispose();
    _heightEditingController.dispose();
    _phoneNumberEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    final appLocalizations = AppLocalizations.of(context)!;

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
          appLocalizations.editProfile,
          style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            children: [
              /// --- CENTERED PROFILE IMAGE ---
              Center(
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: primaryBrandColor, width: 2),
                          ),
                          child: const TCircularImage(
                            image: "assets/images/settings/user.png",
                            width: 100,
                            height: 100,
                            padding: 0,
                          ),
                        ),
                        CircleAvatar(
                          radius: 17,
                          backgroundColor: primaryBrandColor,
                          child: const Icon(Iconsax.camera, color: Colors.white, size: 18),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Change Photo",
                      style: TextStyle(color: primaryBrandColor, fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: TSizes.spaceBtwSections),

              /// --- FORM ---
              Form(
                key: editProfileKey,
                child: Column(
                  children: [
                    /// Name Row
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _firstNameEditingController,
                            validator: (v) => (v == null || v.isEmpty) ? appLocalizations.firstNameRequired : null,
                            decoration: InputDecoration(labelText: appLocalizations.firstName, prefixIcon: const Icon(Iconsax.user)),
                          ),
                        ),
                        const SizedBox(width: TSizes.spaceBtwInputFields),
                        Expanded(
                          child: TextFormField(
                            controller: _lastNameEditingController,
                            validator: (v) => (v == null || v.isEmpty) ? appLocalizations.lastNameRequired : null,
                            decoration: InputDecoration(labelText: appLocalizations.lastName, prefixIcon: const Icon(Iconsax.user)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: TSizes.spaceBtwInputFields),

                    /// Gender Dropdown
                    DropdownButtonFormField<String>(
                      value: _genderEditingController.text.isEmpty ? null : _genderEditingController.text.toLowerCase(),
                      decoration: InputDecoration(labelText: appLocalizations.gender, prefixIcon: const Icon(Iconsax.profile_circle)),
                      items: [
                        DropdownMenuItem(value: 'male', child: Text(appLocalizations.male)),
                        DropdownMenuItem(value: 'female', child: Text(appLocalizations.female)),
                      ],
                      onChanged: (v) => _genderEditingController.text = v ?? '',
                    ),
                    const SizedBox(height: TSizes.spaceBtwInputFields),

                    /// Username (Disabled)
                    TextFormField(
                      controller: _usernameEditingController,
                      enabled: false,
                      decoration: InputDecoration(
                        labelText: appLocalizations.username,
                        prefixIcon: const Icon(Iconsax.user_edit),
                        filled: true,
                        fillColor: dark ? Colors.white10 : Colors.grey[100],
                      ),
                    ),
                    const SizedBox(height: TSizes.spaceBtwInputFields),

                    /// DOB
                    TextFormField(
                      controller: _dateOfBirthEditingController,
                      keyboardType: TextInputType.datetime,
                      decoration: InputDecoration(
                        labelText: appLocalizations.dateOfBirth,
                        hintText: 'DD/MM/YYYY',
                        prefixIcon: const Icon(Iconsax.calendar),
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9/]')),
                        LengthLimitingTextInputFormatter(10),
                        _DateInputFormatter(),
                      ],
                      validator: (v) {
                        if (v == null || v.isEmpty) return appLocalizations.selectDateOfBirth;
                        if (!RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(v)) return appLocalizations.dateOfBirthValidation;
                        return null;
                      },
                    ),
                    const SizedBox(height: TSizes.spaceBtwInputFields),

                    /// Weight & Height Row
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _weightEditingController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: appLocalizations.weight,
                              suffixText: 'kg',
                              prefixIcon: const Icon(Iconsax.weight),
                            ),
                          ),
                        ),
                        const SizedBox(width: TSizes.spaceBtwInputFields),
                        Expanded(
                          child: TextFormField(
                            controller: _heightEditingController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: appLocalizations.height,
                              suffixText: 'cm',
                              prefixIcon: const Icon(Icons.height),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: TSizes.spaceBtwInputFields),

                    /// Phone Number
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.withOpacity(0.2)),
                      ),
                      child: InternationalPhoneNumberInput(
                        onInputChanged: (number) {
                          _phoneNumberEditingController.text = (number.phoneNumber == number.dialCode) ? "" : number.phoneNumber!;
                        },
                        locale: appLocalizations.localeName,
                        selectorConfig: const SelectorConfig(selectorType: PhoneInputSelectorType.DIALOG, useEmoji: true),
                        initialValue: PhoneNumber(phoneNumber: _phoneNumberEditingController.text, isoCode: "LB"),
                        inputDecoration: InputDecoration(
                          labelText: appLocalizations.phoneNumber,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                        selectorTextStyle: TextStyle(color: dark ? Colors.white : Colors.black),
                      ),
                    ),
                    const SizedBox(height: TSizes.spaceBtwSections),

                    /// Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBrandColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _isLoading ? null : _handleSave,
                        child: _isLoading
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Text(appLocalizations.save, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: TSizes.spaceBtwSections),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSave() async {
    final appLocalizations = AppLocalizations.of(context)!;

    if (!editProfileKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final studentService = context.read<StudentService>();
    final student = studentService.student;
    final changes = <String, dynamic>{};

    void addIfChanged(String key, dynamic newVal, dynamic oldVal) {
      if (newVal != null && newVal != oldVal) changes[key] = newVal;
    }

    addIfChanged('first_name', _firstNameEditingController.text.trim(), student?.firstName);
    addIfChanged('last_name', _lastNameEditingController.text.trim(), student?.lastName);
    addIfChanged('gender', _genderEditingController.text.trim(), student?.gender);
    addIfChanged('dob', _dateOfBirthEditingController.text.trim(), student?.dob);
    addIfChanged('weight', int.tryParse(_weightEditingController.text), student?.weight);
    addIfChanged('height', int.tryParse(_heightEditingController.text), student?.height);
    addIfChanged('phone_number', _phoneNumberEditingController.text.trim(), student?.phoneNumber);

    if (changes.isEmpty) {
      setState(() => _isLoading = false);
      Get.back();
      return;
    }

    final success = await studentService.updateFields(student!.userId, changes);
    setState(() => _isLoading = false);

    if (success) {
      Get.back();
      Get.snackbar(
        appLocalizations.success,
        appLocalizations.profileUpdated,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green[800],
        icon: const Icon(Iconsax.tick_circle, color: Colors.green),
        margin: const EdgeInsets.all(15),
        borderRadius: 10,
      );
    } else {
      Get.snackbar(
        appLocalizations.error,
        appLocalizations.errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFDF1E42).withOpacity(0.1), // Your brand red
        colorText: const Color(0xFFDF1E42),
        icon: const Icon(Iconsax.info_circle, color: Color(0xFFDF1E42)),
        margin: const EdgeInsets.all(15),
        borderRadius: 10,
      );
    }
  }
}

class _DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text.replaceAll('/', '');
    if (text.length > 8) text = text.substring(0, 8);
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      if ((i == 1 || i == 3) && i != text.length - 1) buffer.write('/');
    }
    return TextEditingValue(text: buffer.toString(), selection: TextSelection.collapsed(offset: buffer.toString().length));
  }
}
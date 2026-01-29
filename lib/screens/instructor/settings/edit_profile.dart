import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:provider/provider.dart';
import '../../../controllers/instructor/instructor.dart';
import '../../../l10n/app_localizations.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/helpers/helper_functions.dart';
import '../../../utils/widgets/circular_image.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final GlobalKey<FormState> editProfileKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _firstNameEditingController = TextEditingController();
  final TextEditingController _lastNameEditingController = TextEditingController();
  final TextEditingController _genderEditingController = TextEditingController();
  final TextEditingController _usernameEditingController = TextEditingController();
  final TextEditingController _dateOfBirthEditingController = TextEditingController();
  final TextEditingController _phoneNumberEditingController = TextEditingController();

  // Brand Identity
  final Color primaryBrandColor = const Color(0xFFDF1E42);
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final instructor = Provider.of<InstructorService>(context, listen: false).instructor;
      if (instructor != null) {
        _firstNameEditingController.text   = instructor.firstName ?? '';
        _lastNameEditingController.text    = instructor.lastName ?? '';
        _genderEditingController.text      = instructor.gender ?? '';
        _usernameEditingController.text    = instructor.username ?? '';
        _dateOfBirthEditingController.text = instructor.dob ?? '';
        _phoneNumberEditingController.text = instructor.phoneNumber ?? '';
      }
    });
  }

  @override
  void dispose() {
    _firstNameEditingController.dispose();
    _lastNameEditingController.dispose();
    _genderEditingController.dispose();
    _usernameEditingController.dispose();
    _dateOfBirthEditingController.dispose();
    _phoneNumberEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final instructorService = Provider.of<InstructorService>(context);
    final instructor = instructorService.instructor;
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
              /// --- PROFILE IMAGE HEADER ---
              Center(
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: primaryBrandColor, width: 2)),
                          child: TCircularImage(
                            // Use the URL from the instructor object, or fallback to asset
                            image: (instructor?.profilePicture != null && instructor!.profilePicture!.isNotEmpty)
                                ? instructor.profilePicture!
                                : "assets/images/settings/user.png",
                            width: 100,
                            height: 100,
                          ),
                        ),
                        GestureDetector(
                          onTap: _pickAndUploadImage,
                          child: CircleAvatar(
                            radius: 17,
                            backgroundColor: primaryBrandColor,
                            child: const Icon(Iconsax.camera, color: Colors.white, size: 18),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: TSizes.spaceBtwSections),

              /// --- EDIT FORM ---
              Form(
                key: editProfileKey,
                child: Column(
                  children: [
                    /// First & Last Name
                    Row(
                      children: [
                        Expanded(
                          child: _buildInputWrapper(
                            child: TextFormField(
                              controller: _firstNameEditingController,
                              validator: (v) => (v == null || v.isEmpty) ? appLocalizations.firstNameRequired : null,
                              decoration: InputDecoration(
                                labelText: appLocalizations.firstName,
                                prefixIcon: const Icon(Iconsax.user),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: TSizes.spaceBtwInputFields),
                        Expanded(
                          child: _buildInputWrapper(
                            child: TextFormField(
                              controller: _lastNameEditingController,
                              validator: (v) => (v == null || v.isEmpty) ? appLocalizations.lastNameRequired : null,
                              decoration: InputDecoration(
                                labelText: appLocalizations.lastName,
                                prefixIcon: const Icon(Iconsax.user),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: TSizes.spaceBtwInputFields),

                    /// Gender Dropdown
                    _buildInputWrapper(
                      child: DropdownButtonFormField<String>(
                        value: _genderEditingController.text.isEmpty ? null : _genderEditingController.text.toLowerCase(),
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 14),
                        decoration: InputDecoration(
                          labelText: appLocalizations.gender,
                          prefixIcon: const Icon(Iconsax.profile_circle),
                        ),
                        items: [
                          DropdownMenuItem(value: 'male', child: Text(appLocalizations.male)),
                          DropdownMenuItem(value: 'female', child: Text(appLocalizations.female)),
                        ],
                        onChanged: (value) => _genderEditingController.text = value ?? '',
                        validator: (value) => (value == null || value.isEmpty) ? appLocalizations.pleaseSelectGender : null,
                      ),
                    ),
                    const SizedBox(height: TSizes.spaceBtwInputFields),

                    /// Username (Disabled/Read-Only Style)
                    _buildInputWrapper(
                      child: TextFormField(
                        controller: _usernameEditingController,
                        enabled: false,
                        decoration: InputDecoration(
                          labelText: appLocalizations.username,
                          prefixIcon: const Icon(Iconsax.user_edit),
                          filled: true,
                          fillColor: dark ? Colors.white10 : Colors.grey[100],
                        ),
                      ),
                    ),
                    const SizedBox(height: TSizes.spaceBtwInputFields),

                    /// Date of Birth
                    _buildInputWrapper(
                      child: TextFormField(
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
                        validator: (value) {
                          if (!RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(value!)) return appLocalizations.dateOfBirthValidation;
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: TSizes.spaceBtwInputFields),

                    /// Phone Number
                    _buildInputWrapper(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.withOpacity(0.2)),
                        ),
                        child: InternationalPhoneNumberInput(
                          onInputChanged: (PhoneNumber number) {
                            _phoneNumberEditingController.text = (number.phoneNumber == number.dialCode) ? "" : number.phoneNumber!;
                          },
                          locale: appLocalizations.localeName,
                          selectorConfig: const SelectorConfig(
                            selectorType: PhoneInputSelectorType.DIALOG,
                            useEmoji: true,
                          ),
                          initialValue: PhoneNumber(
                              phoneNumber: _phoneNumberEditingController.text,
                              isoCode: "LB"
                          ),
                          inputDecoration: InputDecoration(
                            labelText: appLocalizations.phoneNumber,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                          ),
                          selectorTextStyle: TextStyle(color: dark ? Colors.white : Colors.black),
                        ),
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
                            : Text(
                          appLocalizations.save,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
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

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);

    if (image != null) {
      final File file = File(image.path);

      final int sizeInBytes = file.lengthSync();
      final double sizeInMb = sizeInBytes / (1024 * 1024);

      if (sizeInMb > 2.0) {
        Get.snackbar(
          "File Too Large",
          "Image must be smaller than 2MB. Your file: ${sizeInMb.toStringAsFixed(2)}MB",
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return; // Stop the process here
      }
      setState(() => _isLoading = true);

      final instructorService = Provider.of<InstructorService>(context, listen: false);
      String? imageUrl = await instructorService.uploadProfilePicture(file);

      setState(() => _isLoading = false);

      if (imageUrl != null) {
        Get.snackbar("Success", "Profile picture updated!");
      } else {
        Get.snackbar("Error", "Failed to upload image.");
      }
    }
  }

  /// Optional wrapper for extra styling consistency
  Widget _buildInputWrapper({required Widget child}) {
    return child;
  }

  /// --- LOGIC: SAVE PROFILE ---
  Future<void> _handleSave() async {
    final appLocalizations = AppLocalizations.of(context)!;

    if (!editProfileKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final instructorService = context.read<InstructorService>();
    final instructor = instructorService.instructor;
    final changes = <String, dynamic>{};

    void addIfChanged(String key, dynamic newVal, dynamic oldVal) {
      if (newVal != null && newVal != oldVal) {
        changes[key] = newVal;
      }
    }

    addIfChanged('first_name', _firstNameEditingController.text.trim(), instructor?.firstName);
    addIfChanged('last_name', _lastNameEditingController.text.trim(), instructor?.lastName);
    addIfChanged('gender', _genderEditingController.text.trim(), instructor?.gender);
    addIfChanged('dob', _dateOfBirthEditingController.text.trim(), instructor?.dob);
    addIfChanged('phone_number', _phoneNumberEditingController.text.trim(), instructor?.phoneNumber);

    if (changes.isEmpty) {
      setState(() => _isLoading = false);
      Get.back();
      return;
    }

    final success = await instructorService.updateFields(instructor!.userId, changes);

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

/// --- DATE FORMATTER ---
class _DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text.replaceAll('/', '');
    if (text.length > 8) text = text.substring(0, 8);

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
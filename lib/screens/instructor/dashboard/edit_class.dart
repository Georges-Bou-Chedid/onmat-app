import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

import '../../../controllers/i_class.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/Class.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/helpers/helper_functions.dart';
import '../../../utils/widgets/background_image_header_container.dart';
import '../start.dart';

class EditClassScreen extends StatefulWidget {
  final Class classItem;

  const EditClassScreen({super.key, required this.classItem});

  @override
  State<EditClassScreen> createState() => _EditClassScreenState();
}

class _EditClassScreenState extends State<EditClassScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameCtrl;
  late TextEditingController countryCtrl;
  Country? _selectedCountry;
  late TextEditingController locationCtrl;
  late AppLocalizations appLocalizations;
  String? selectedType;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.classItem.className);
    selectedType = widget.classItem.classType;
    _selectedCountry = Country.parse(widget.classItem.country ?? 'LB');
    countryCtrl = TextEditingController(text: _selectedCountry!.name);
    locationCtrl = TextEditingController(text: widget.classItem.location);
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    countryCtrl.dispose();
    locationCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    appLocalizations = AppLocalizations.of(context)!;
    final dark = THelperFunctions.isDarkMode(context);

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            /// -- Header
            TBackgroundImageHeaderContainer(
              image: 'assets/images/class_details_background.jpg',
              child: Column(
                children: [
                  /// AppBar
                  Container(
                    height: 150, // enough height for your image
                    padding: EdgeInsets.only(top: TSizes.defaultSpace),
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                          onPressed: () => Get.back(),
                        ),
                        GestureDetector(
                          onTap: () => Get.offAll(() => const StartScreen()),
                          child: Image.asset(
                            'assets/images/logo-white.png',
                            width: 80,
                            height: 80,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    ),
                  ),

                  ListTile(
                    title: Text(
                        'Edit Class',
                        style: Theme.of(context).textTheme.headlineSmall!.apply(color: Colors.white)
                    ),
                  ),
                  const SizedBox(height: TSizes.appBarHeight)
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(TSizes.defaultSpace),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // 1. Class Name
                    TextFormField(
                      controller: nameCtrl,
                      decoration: InputDecoration(
                        labelText: appLocalizations.className,
                        prefixIcon: Icon(Iconsax.text),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty ? appLocalizations.required : null,
                    ),
                    const SizedBox(height: TSizes.spaceBtwItems),

                    // 2. Class Type
                    DropdownButtonFormField<String>(
                      value: selectedType,
                      decoration: InputDecoration(
                        labelText: appLocalizations.classType,
                        prefixIcon: Icon(Iconsax.tag),
                      ),
                      dropdownColor: dark ? Color(0xFF1E1E1E) : Colors.white,
                      borderRadius: BorderRadius.circular(20.0),
                      items: [
                        DropdownMenuItem(value: 'Jiu‑Jitsu',  child: Text('Jiu‑Jitsu')),
                        DropdownMenuItem(value: 'Muay Thai',  child: Text('Muay Thai')),
                        DropdownMenuItem(value: 'Boxing',     child: Text('Boxing')),
                        DropdownMenuItem(value: 'Karate',     child: Text('Karate')),
                        DropdownMenuItem(value: 'Taekwondo',  child: Text('Taekwondo')),
                        DropdownMenuItem(value: 'MMA',        child: Text('MMA')),
                        DropdownMenuItem(value: 'Yoga',       child: Text('Yoga')),
                        DropdownMenuItem(value: 'Pilates',    child: Text('Pilates')),
                        DropdownMenuItem(value: 'Strength Training',   child: Text('Strength Training')),
                        DropdownMenuItem(value: 'Conditioning',  child: Text('Conditioning')),
                      ],
                      onChanged: (String? value) {
                        setState(() {
                          selectedType = value;
                        });
                      },
                      validator: (v) => v == null ? appLocalizations.required : null,
                    ),
                    const SizedBox(height: TSizes.spaceBtwItems),

                    // 3. Country (string)
                    GestureDetector(
                      onTap: () {
                        showCountryPicker(
                          context: context,
                          showPhoneCode:
                          false, // set true if you also need dial codes like +961
                          countryListTheme: CountryListThemeData(
                            borderRadius: BorderRadius.circular(20),
                            inputDecoration: InputDecoration(
                              labelText: appLocalizations.searchCountry,
                              prefixIcon: const Icon(Icons.search),
                            ),
                          ),
                          onSelect: (Country country) {
                            setState(() {
                              _selectedCountry = country;
                              countryCtrl.text = country.name;
                            });
                          },
                        );
                      },
                      child: AbsorbPointer(          // prevents keyboard
                        child: TextFormField(
                            controller: countryCtrl,
                            decoration: InputDecoration(
                              labelText: appLocalizations.country,
                              prefixIcon: Padding(
                                padding: const EdgeInsets.only(left: 12, right: 8, top: 5),
                                child: Text(
                                  _selectedCountry!.flagEmoji,
                                  style: const TextStyle(fontSize: 22),
                                ),
                              ),
                              suffixIcon: const Icon(Icons.arrow_drop_down),
                            ),
                            validator: (v) => v == null || v.trim().isEmpty ? appLocalizations.required : null,
                            readOnly: true
                        ),
                      ),
                    ),
                    const SizedBox(height: TSizes.spaceBtwItems),

                    // 4. Location (string)
                    TextFormField(
                      controller: locationCtrl,
                      decoration: InputDecoration(
                        labelText: appLocalizations.location,
                        hintText: appLocalizations.locationHint,
                        prefixIcon: Icon(Iconsax.location),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty ? appLocalizations.required : null,
                    ),
                    const SizedBox(height: TSizes.defaultSpace),

                    ElevatedButton(
                      onPressed: _isSaving
                          ? null
                          : () async {
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            _isSaving = true;
                          });

                          final classService = context.read<InstructorClassService>();

                          final changes = <String, dynamic>{};

                          void addIfChanged(String key, dynamic newVal, dynamic oldVal) {
                            if (newVal != null && newVal != oldVal) changes[key] = newVal;
                          }

                          addIfChanged('class_name', nameCtrl.text.trim(), widget.classItem.className);
                          addIfChanged('class_type', selectedType, widget.classItem.classType);
                          addIfChanged('country', _selectedCountry!.countryCode, widget.classItem.country);
                          addIfChanged('location', locationCtrl.text.trim(), widget.classItem.location);

                          // Nothing to update?
                          if (changes.isEmpty) {
                            setState(() => _isSaving = false);
                            return;
                          }

                          // 3. call service
                          final success = await classService.updateFields(widget.classItem.id, changes);

                          setState(() {
                            _isSaving = false;
                          });

                          if (success) {
                            Get.back();
                            Get.snackbar(
                              appLocalizations.success,
                              appLocalizations.classUpdatedMessage,
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          } else {
                            Get.snackbar(
                              appLocalizations.error,
                              appLocalizations.errorMessage,
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          }
                        }
                      },
                      child: _isSaving
                          ? const SizedBox(
                        height: TSizes.md,
                        width: TSizes.md,
                        child: CircularProgressIndicator(),
                      ) : Text(
                        appLocalizations.saveChanges,
                        style: const TextStyle(
                            fontFamily: "Inter",
                            fontSize: 14,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

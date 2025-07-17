import 'package:country_picker/country_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:onmat/controllers/class.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../../l10n/app_localizations.dart';
import '../../../models/Class.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/helpers/helper_functions.dart';
import '../../../utils/widgets/background_image_header_container.dart';
import '../start.dart';

class AddClassScreen extends StatefulWidget {
  const AddClassScreen({super.key});

  @override
  _AddClassScreenState createState() => _AddClassScreenState();
}

class _AddClassScreenState extends State<AddClassScreen> {
  final GlobalKey<FormState> createClassKey = GlobalKey<FormState>();
  final TextEditingController nameCtrl       = TextEditingController();
  final TextEditingController locationCtrl   = TextEditingController();
  Country? _selectedCountry;
  final TextEditingController countryCtrl    = TextEditingController();
  late AppLocalizations appLocalizations;
  String? selectedType;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedCountry = Country.parse('LB');   // Lebanon 🇱🇧
    countryCtrl.text = _selectedCountry!.name;
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    locationCtrl.dispose();
    countryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ClassService classService = Provider.of<ClassService>(context);
    appLocalizations = AppLocalizations.of(context)!;
    final dark = THelperFunctions.isDarkMode(context);

    return Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              /// -- Header
              TBackgroundImageHeaderContainer(
                image: 'assets/images/fitness_background.jpg',
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

                    /// Classes Card
                    ListTile(
                      title: Text(
                          appLocalizations.createClass,
                          style: Theme.of(context).textTheme.headlineSmall!.apply(color: Colors.white)
                      ),
                    ),
                    const SizedBox(height: TSizes.spaceBtwSections)
                  ],
                ),
              ),

              /// Body
              Form(
                key: createClassKey,
                child: Padding(
                  padding: const EdgeInsets.all(TSizes.spaceBtwItems),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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

                      // Save button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isSaving
                              ? null
                              : () async {
                            if (createClassKey.currentState?.validate() ?? false) {
                              setState(() {
                                _isSaving = true;
                              });

                              final String qrCode = const Uuid().v4();
                              Class cl = Class(
                                  ownerId: FirebaseAuth.instance.currentUser?.uid,
                                  className: nameCtrl.text.trim(),
                                  classType: selectedType,
                                  country: countryCtrl.text.trim(),
                                  location: locationCtrl.text.trim(),
                                  qrCode: qrCode
                              );

                              final success = await classService.createClass(cl);

                              setState(() {
                                _isSaving = false;
                              });

                              if (success) {
                                Get.back();
                                Get.snackbar(
                                  appLocalizations.success,
                                  appLocalizations.classCreatedMessage,
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
                            appLocalizations.create,
                            style: const TextStyle(
                                fontFamily: "Inter",
                                fontSize: 14,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        )
    );
  }
}

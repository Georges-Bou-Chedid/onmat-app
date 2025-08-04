import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

import '../../../l10n/app_localizations.dart';
import '../../../models/Class.dart';
import '../../../utils/helpers/helper_functions.dart';
import '../../controllers/instructor/instructor_class.dart';
import '../constants/sizes.dart';

class EditClassDialog extends StatefulWidget {
  final Class classItem;

  const EditClassDialog({super.key, required this.classItem});

  @override
  State<EditClassDialog> createState() => _EditClassDialogState();
}

class _EditClassDialogState extends State<EditClassDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameCtrl;
  late TextEditingController countryCtrl;
  late TextEditingController locationCtrl;
  Country? _selectedCountry;
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
    final appLocalizations = AppLocalizations.of(context)!;
    final instructorClassService = context.read<InstructorClassService>();
    final dark = THelperFunctions.isDarkMode(context);

    return Dialog(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
          maxWidth: 500,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  appLocalizations.editClass,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: TSizes.defaultSpace),

                // Class Name
                TextFormField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: appLocalizations.className,
                    prefixIcon: Icon(Iconsax.text),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? appLocalizations.required : null,
                ),
                const SizedBox(height: TSizes.spaceBtwItems),

                // Class Type
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

                // Country Picker
                GestureDetector(
                  onTap: () {
                    showCountryPicker(
                      context: context,
                      showPhoneCode: false,
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
                  child: AbsorbPointer(
                    child: TextFormField(
                      controller: countryCtrl,
                      readOnly: true,
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
                    ),
                  ),
                ),
                const SizedBox(height: TSizes.spaceBtwItems),

                // Location
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

                // Save / Cancel
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: Text(appLocalizations.cancel),
                    ),
                    const SizedBox(width: TSizes.sm),
                    ElevatedButton(
                      onPressed: _isSaving
                          ? null
                          : () async {
                        if (_formKey.currentState!.validate()) {
                          setState(() => _isSaving = true);
                          final changes = <String, dynamic>{};

                          void addIfChanged(String key, dynamic newVal, dynamic oldVal) {
                            if (newVal != null && newVal != oldVal) changes[key] = newVal;
                          }

                          addIfChanged('class_name', nameCtrl.text.trim(), widget.classItem.className);
                          addIfChanged('class_type', selectedType, widget.classItem.classType);
                          addIfChanged('country', _selectedCountry!.countryCode, widget.classItem.country);
                          addIfChanged('location', locationCtrl.text.trim(), widget.classItem.location);

                          if (changes.isEmpty) {
                            setState(() => _isSaving = false);
                            return;
                          }

                          final success = await instructorClassService.updateFields(widget.classItem.id, changes);

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

                          setState(() => _isSaving = false);
                        }
                      },
                      child: _isSaving
                          ? const SizedBox(height: 15, width: 15, child: CircularProgressIndicator())
                          : Text(appLocalizations.saveChanges),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

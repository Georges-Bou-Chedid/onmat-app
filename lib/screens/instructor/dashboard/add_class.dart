import 'package:country_picker/country_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../../controllers/instructor/instructor_class.dart';
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
  final TextEditingController countryCtrl    = TextEditingController();
  Country? _selectedCountry;
  List<Map<String, String>> schedule = [];
  List<Map<String, String?>> scheduleErrors = [];
  late AppLocalizations appLocalizations;
  String? selectedType;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedCountry = Country.parse('LB');
    countryCtrl.text = _selectedCountry!.name;
    schedule = [];
    scheduleErrors = List.generate(schedule.length, (_) => {'day': null, 'time': null, 'duration': null});
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    locationCtrl.dispose();
    countryCtrl.dispose();
    super.dispose();
  }

  bool validateSchedule() {
    bool valid = true;

    scheduleErrors = List.generate(schedule.length, (_) => {'day': null, 'time': null, 'duration': null});

    for (int i = 0; i < schedule.length; i++) {
      final item = schedule[i];
      if (item['day'] == null || item['day']!.trim().isEmpty) {
        scheduleErrors[i]['day'] = appLocalizations.required;
        valid = false;
      }
      if (item['time'] == null || item['time']!.trim().isEmpty) {
        scheduleErrors[i]['time'] = appLocalizations.required;
        valid = false;
      }
      if (item['duration'] == null || item['duration']!.trim().isEmpty) {
        scheduleErrors[i]['duration'] = appLocalizations.required;
        valid = false;
      }
    }

    setState(() {}); // Update UI to show errors
    return valid;
  }

  @override
  Widget build(BuildContext context) {
    final InstructorClassService instructorClassService = Provider.of<InstructorClassService>(context);
    appLocalizations = AppLocalizations.of(context)!;
    final dark = THelperFunctions.isDarkMode(context);
    final List<String> weekdays = [
      appLocalizations.monday, appLocalizations.tuesday, appLocalizations.wednesday, appLocalizations.thursday, appLocalizations.friday, appLocalizations.saturday, appLocalizations.sunday
    ];

    return Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              /// -- Header
              TBackgroundImageHeaderContainer(
                image: 'assets/images/create_class_background.jpg',
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
                  padding: const EdgeInsets.all(TSizes.defaultSpace),
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
                      const SizedBox(height: TSizes.spaceBtwItems),

                      // Schedule List
                      Column(
                        children: schedule.asMap().entries.map((entry) {
                          int index = entry.key;
                          Map<String, String> item = entry.value;

                          return Card(
                            elevation: 4,
                            margin: const EdgeInsets.symmetric(vertical: TSizes.xs),
                            child: Padding(
                              padding: const EdgeInsets.all(TSizes.sm),
                              child: Column(
                                children: [
                                  // Day Dropdown
                                  DropdownButtonFormField<String>(
                                    value: weekdays.contains(item['day']) ? item['day'] : null,
                                    items: weekdays.map((day) {
                                      return DropdownMenuItem(value: day, child: Text(day));
                                    }).toList(),
                                    decoration: InputDecoration(
                                      labelText: appLocalizations.day,
                                      prefixIcon: const Icon(Iconsax.calendar),
                                      errorText: scheduleErrors.length > index ? scheduleErrors[index]['day'] : null,
                                    ),
                                    onChanged: (val) {
                                      setState(() {
                                        if (schedule.length > index) {
                                          schedule[index] = schedule[index] ?? {};
                                          schedule[index]['day'] = val!;
                                          if (scheduleErrors.length > index) {
                                            scheduleErrors[index]['day'] = null;
                                          }
                                        }
                                      });
                                    },

                                  ),
                                  const SizedBox(height: TSizes.spaceBtwItems),

                                  // Time Field
                                  TextFormField(
                                    controller: TextEditingController(text: item['time']),
                                    readOnly: true,
                                    decoration: InputDecoration(
                                      labelText: appLocalizations.time,
                                      prefixIcon: const Icon(Icons.access_time),
                                      errorText: scheduleErrors.length > index ? scheduleErrors[index]['time'] : null,
                                    ),
                                    onTap: () async {
                                      final TimeOfDay? pickedTime = await showTimePicker(
                                        context: context,
                                        initialTime: TimeOfDay.now(),
                                        builder: (BuildContext context, Widget? child) {
                                          return MediaQuery(
                                            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
                                            child: child!,
                                          );
                                        },
                                      );

                                      if (pickedTime != null) {
                                        final formattedTime = pickedTime.format(context);
                                        setState(() {
                                          schedule[index]['time'] = formattedTime;
                                          if (scheduleErrors.length > index) {
                                            scheduleErrors[index]['time'] = null;
                                          }
                                        });
                                      }
                                    },
                                  ),
                                  const SizedBox(height: TSizes.spaceBtwItems),

                                  // Duration Field
                                  TextFormField(
                                    initialValue: item['duration'],
                                    decoration: InputDecoration(
                                      labelText: appLocalizations.duration,
                                      prefixIcon: Icon(Iconsax.timer),
                                      errorText: scheduleErrors.length > index ? scheduleErrors[index]['duration'] : null,
                                    ),
                                    onChanged: (val) {
                                      if (schedule.length > index) {
                                        schedule[index] = schedule[index] ?? {};
                                        schedule[index]['duration'] = val;
                                        if (scheduleErrors.length > index) {
                                          scheduleErrors[index]['duration'] = null;
                                        }
                                      }
                                    },
                                  ),

                                  // Remove button
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: IconButton(
                                      icon: const Icon(Iconsax.trash, color: Color(0xFFDF1E42)),
                                      onPressed: () {
                                        setState(() => schedule.removeAt(index));
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: TSizes.spaceBtwItems),

                      // Add Schedule Entry Button
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            schedule.add({});
                          });
                        },
                        icon: const Icon(Iconsax.calendar_add),
                        label: Text(appLocalizations.addSchedule),
                      ),
                      const SizedBox(height: TSizes.defaultSpace),

                      // Save button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isSaving
                              ? null
                              : () async {
                            if (createClassKey.currentState!.validate() && validateSchedule()) {
                              setState(() {
                                _isSaving = true;
                              });

                              Class cl = Class(
                                id: '',
                                ownerId: FirebaseAuth.instance.currentUser?.uid,
                                className: nameCtrl.text.trim(),
                                classType: selectedType,
                                country: _selectedCountry?.countryCode,
                                location: locationCtrl.text.trim(),
                                schedule: schedule
                              );

                              final success = await instructorClassService.createClass(cl);

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

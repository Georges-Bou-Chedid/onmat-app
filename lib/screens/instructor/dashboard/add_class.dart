import 'package:country_picker/country_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../../controllers/classItem/class_graduation.dart';
import '../../../controllers/instructor/instructor_class.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/Belt.dart';
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
  List<Belt> graduationBelts = [];

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

  bool hasOverlap(Belt newBelt, List<Belt> existingBelts) {
    for (final b in existingBelts) {
      final sameBeltColor =
              b.beltColor1.value == newBelt.beltColor1.value &&
              (b.beltColor2?.value ?? -1) == (newBelt.beltColor2?.value ?? -1);

      if (sameBeltColor) {
        if (!(newBelt.maxAge < b.minAge || newBelt.minAge > b.maxAge)) {
          return true;
        }
      }
    }
    return false;
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
                          appLocalizations.addClass,
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
                      Center(
                        child: Text(
                          appLocalizations.classInfo,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: TSizes.spaceBtwItems),

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
                          DropdownMenuItem(value: 'Jiu‑Jitsu',  child: Text(appLocalizations.jiujitsu)),
                          // DropdownMenuItem(value: 'Muay Thai',  child: Text('Muay Thai')),
                          // DropdownMenuItem(value: 'Boxing',     child: Text('Boxing')),
                          // DropdownMenuItem(value: 'Karate',     child: Text('Karate')),
                          // DropdownMenuItem(value: 'Taekwondo',  child: Text('Taekwondo')),
                          // DropdownMenuItem(value: 'MMA',        child: Text('MMA')),
                          // DropdownMenuItem(value: 'Yoga',       child: Text('Yoga')),
                          // DropdownMenuItem(value: 'Pilates',    child: Text('Pilates')),
                          // DropdownMenuItem(value: 'Strength Training',   child: Text('Strength Training')),
                          // DropdownMenuItem(value: 'Conditioning',  child: Text('Conditioning')),
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





                    /// Graduation System
                    if (selectedType != null) ...[
                      Center(
                        child: Text(
                          appLocalizations.graduationSystem,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: TSizes.spaceBtwItems),

                      Center(
                        child: ElevatedButton.icon(
                          icon: Icon(Iconsax.additem),
                          label: Text(appLocalizations.addBeltPerOrder),
                          onPressed: () async {
                            final belt = await showDialog<Belt>(
                              context: context,
                              builder: (context) {
                                RangeValues ageRange = const RangeValues(5, 15);
                                final classesController = TextEditingController();

                                Color selectedColor = Colors.white;
                                Color? selectedColor2;

                                return StatefulBuilder(
                                  builder: (context, setState) => AlertDialog(
                                    title: Text(appLocalizations.addBelt),
                                    content: SingleChildScrollView(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          /// Age Range with  Slider
                                          Text(
                                            "${appLocalizations.ageRange}: ${ageRange.start.round()} – ${ageRange.end.round()}",
                                            style: Theme.of(context).textTheme.bodyMedium,
                                          ),
                                          RangeSlider(
                                            values: ageRange,
                                            min: 1,
                                            max: 100,
                                            divisions: 99,
                                            labels: RangeLabels(
                                              ageRange.start.round().toString(),
                                              ageRange.end.round().toString(),
                                            ),
                                            onChanged: (RangeValues values) {
                                              setState(() {
                                                ageRange = values;
                                              });
                                            },
                                          ),

                                          const SizedBox(height: TSizes.inputFieldRadius),

                                          /// Classes per Stripe
                                          TextField(
                                            controller: classesController,
                                            keyboardType: TextInputType.number,
                                            decoration: InputDecoration(labelText: appLocalizations.classesPerBeltOrStripe),
                                          ),

                                          const SizedBox(height: TSizes.inputFieldRadius),

                                          /// Belt Color 1 Picker
                                          Row(
                                            children: [
                                              Text(appLocalizations.beltColor),
                                              const SizedBox(width: TSizes.sm),
                                              GestureDetector(
                                                onTap: () async {
                                                  final color = await showDialog<Color>(
                                                    context: context,
                                                    builder: (context) => AlertDialog(
                                                      title: Text(appLocalizations.pickBeltColor),
                                                      content: Container(
                                                        padding: EdgeInsets.all(TSizes.sm),
                                                        decoration: BoxDecoration(
                                                          color: Colors.grey[300],
                                                          borderRadius: BorderRadius.circular(TSizes.inputFieldRadius),
                                                        ),
                                                        child: BlockPicker(
                                                          pickerColor: selectedColor,
                                                          onColorChanged: (c) => Navigator.pop(context, c),
                                                          availableColors: [
                                                            Colors.white,
                                                            Colors.grey,
                                                            Colors.yellow,
                                                            Colors.orange,
                                                            Colors.green,
                                                            Colors.blue,
                                                            Colors.purple,
                                                            Colors.brown,
                                                            Colors.black,
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                  if (color != null) {
                                                    setState(() => selectedColor = color);
                                                  }
                                                },
                                                child: Container(
                                                  width: 24,
                                                  height: 35,
                                                  decoration: BoxDecoration(
                                                    color: selectedColor,
                                                    border: Border.all(color: Colors.black, width: 1.5),
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                )
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: TSizes.inputFieldRadius),

                                          /// Belt Color 2 Picker
                                          Row(
                                            children: [
                                              Text(appLocalizations.beltColor2),
                                              const SizedBox(width: TSizes.sm),
                                              GestureDetector(
                                                onTap: () async {
                                                  final color = await showDialog<Color>(
                                                    context: context,
                                                    builder: (context) => AlertDialog(
                                                      title: Text(appLocalizations.pickBeltColor),
                                                      content: Container(
                                                        padding: EdgeInsets.all(TSizes.sm),
                                                        decoration: BoxDecoration(
                                                          color: Colors.grey[300],
                                                          borderRadius: BorderRadius.circular(TSizes.inputFieldRadius),
                                                        ),
                                                        child: BlockPicker(
                                                          pickerColor: selectedColor2 ?? Colors.transparent,
                                                          onColorChanged: (c) => Navigator.pop(context, c),
                                                          availableColors: [
                                                            Colors.white,
                                                            Colors.grey,
                                                            Colors.yellow,
                                                            Colors.orange,
                                                            Colors.green,
                                                            Colors.blue,
                                                            Colors.purple,
                                                            Colors.brown,
                                                            Colors.black,
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                  if (color != null) {
                                                    setState(() => selectedColor2 = color);
                                                  }
                                                },
                                                child: selectedColor2 != null
                                                    ? Container(
                                                      width: 24,
                                                      height: 35,
                                                      decoration: BoxDecoration(
                                                        color: selectedColor2,
                                                        border: Border.all(color: Colors.black, width: 1.5),
                                                        borderRadius: BorderRadius.circular(4),
                                                      ),
                                                    )
                                                    : Container(
                                                        decoration: BoxDecoration(
                                                          shape: BoxShape.circle,
                                                          border: Border.all(
                                                            color: Colors.black,
                                                            width: 1,
                                                          ),
                                                        ),
                                                        child: CircleAvatar(
                                                          backgroundColor: Colors.grey.shade300,
                                                          child: Icon(Iconsax.add, color: Colors.black54)
                                                        ),
                                                      ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: TSizes.inputFieldRadius),
                                        ],
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text(appLocalizations.cancel),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          final minAge = ageRange.start.round();
                                          final maxAge = ageRange.end.round();
                                          final classes = int.tryParse(classesController.text.trim());

                                          if (classes != null) {
                                            final newBelt = Belt(
                                              id: Uuid().v4(),
                                              minAge: minAge,
                                              maxAge: maxAge,
                                              beltColor1: selectedColor,
                                              beltColor2: selectedColor2,
                                              classesPerBeltOrStripe: classes,
                                              priority: graduationBelts.length + 1,
                                            );

                                            if (hasOverlap(newBelt, graduationBelts)) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text(appLocalizations.ageRangeOverlaps)),
                                              );
                                            } else {
                                              Navigator.pop(context, newBelt);
                                            }
                                          }
                                        },
                                        child: Text(appLocalizations.save),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );

                            if (belt != null) {
                              setState(() => graduationBelts.add(belt));
                            }
                          },
                        ),
                      ),

                      if (graduationBelts.isNotEmpty)
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: graduationBelts.length,
                          itemBuilder: (context, index) {
                            final belt = graduationBelts[index];
                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    belt.beltColor2 != null
                                        ? Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 24,
                                          height: 35,
                                          decoration: BoxDecoration(
                                            color: belt.beltColor1,
                                            border: Border.all(color: Colors.black, width: 1.5),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Container(
                                          width: 24,
                                          height: 35,
                                          decoration: BoxDecoration(
                                            color: belt.beltColor2,
                                            border: Border.all(color: Colors.black, width: 1.5),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                        ),
                                      ],
                                    )
                                    : Container(
                                      width: 24,
                                      height: 35,
                                      decoration: BoxDecoration(
                                        color: belt.beltColor1,
                                        border: Border.all(color: Colors.black, width: 1.5),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),

                                    const SizedBox(width: 16),

                                    // Details
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Wrap(
                                            spacing: 8,
                                            children: [
                                              Row(
                                                children: [
                                                  Chip(
                                                    label: Text(
                                                      "${belt.minAge}–${belt.maxAge} ${appLocalizations.years}",
                                                      style: const TextStyle(fontWeight: FontWeight.w500),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Chip(
                                                    label: belt.beltColor2 == null
                                                        ? Text(Belt.getColorName(belt.beltColor1))
                                                        : Text("${Belt.getColorName(belt.beltColor1)}/${Belt.getColorName(belt.beltColor2!)}",
                                                      style: const TextStyle(fontWeight: FontWeight.w500),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Chip(
                                                label: Text(
                                                  "${belt.classesPerBeltOrStripe} ${appLocalizations.classesPerBeltOrStripe}",
                                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Delete button
                                    IconButton(
                                      icon: const Icon(Iconsax.trash, color: Color(0xFFDF1E42)),
                                      onPressed: () {
                                        setState(() => graduationBelts.removeAt(index));
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),


                      const SizedBox(height: TSizes.defaultSpace),
                    ],


                      /// Schedule List
                      Center(
                        child: Text(
                          appLocalizations.addSchedule,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: TSizes.spaceBtwItems),

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

                      // Add Schedule Entry Button
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              schedule.add({});
                            });
                          },
                          icon: const Icon(Iconsax.calendar_add),
                          label: Text(appLocalizations.addSchedule),
                        ),
                      ),
                      const SizedBox(height: TSizes.appBarHeight),




                      /// Save button
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

                              final classId = await instructorClassService.createClass(cl);

                              setState(() {
                                _isSaving = false;
                              });

                              if (classId != null) {
                                final graduationService = ClassGraduationService();
                                final success = await graduationService.setBeltsForClass(classId, graduationBelts);

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

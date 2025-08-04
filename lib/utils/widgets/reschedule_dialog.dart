import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

import '../../controllers/instructor/instructor_class.dart';
import '../../l10n/app_localizations.dart';
import '../constants/sizes.dart';

class RescheduleDialog extends StatefulWidget {
  final String classId;
  final List<Map<String, String>> initialSchedule;

  const RescheduleDialog({
    super.key,
    required this.initialSchedule,
    required this.classId,
  });

  @override
  State<RescheduleDialog> createState() => _RescheduleDialogState();
}

class _RescheduleDialogState extends State<RescheduleDialog> {
  late List<Map<String, String>> schedule;
  late List<Map<String, String?>> scheduleErrors;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    schedule = widget.initialSchedule.map((e) => Map<String, String>.from(e)).toList();
    scheduleErrors = List.generate(schedule.length, (_) => {'day': null, 'time': null, 'duration': null});
  }

  bool _validate() {
    bool isValid = true;
    for (int i = 0; i < schedule.length; i++) {
      final item = schedule[i];
      final errors = <String, String?>{};
      if ((item['day'] ?? '').isEmpty) {
        errors['day'] = 'Required';
        isValid = false;
      }
      if ((item['time'] ?? '').isEmpty) {
        errors['time'] = 'Required';
        isValid = false;
      }
      if ((item['duration'] ?? '').isEmpty) {
        errors['duration'] = 'Required';
        isValid = false;
      }
      scheduleErrors[i] = errors;
    }
    setState(() {});
    return isValid;
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    final instructorClassService = context.read<InstructorClassService>();
    final List<String> weekdays = [
      appLocalizations.monday, appLocalizations.tuesday, appLocalizations.wednesday, appLocalizations.thursday, appLocalizations.friday, appLocalizations.saturday, appLocalizations.sunday
    ];

    return Dialog(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          maxWidth: 500,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(appLocalizations.reschedule, style: Theme.of(context).textTheme.titleLarge),

              const SizedBox(height: TSizes.spaceBtwItems),
              ...schedule.asMap().entries.map((entry) {
                int index = entry.key;
                Map<String, String> item = entry.value;

                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: TSizes.xs),
                  child: Padding(
                    padding: const EdgeInsets.all(TSizes.borderRadiusLg),
                    child: Column(
                      children: [
                        // Day dropdown
                        DropdownButtonFormField<String>(
                          value: weekdays.contains(item['day']) ? item['day'] : null,
                          items: weekdays.map((day) => DropdownMenuItem(value: day, child: Text(day))).toList(),
                          decoration: InputDecoration(
                            labelText: appLocalizations.day,
                            prefixIcon: const Icon(Iconsax.calendar),
                            errorText: scheduleErrors[index]['day'],
                          ),
                          onChanged: (val) {
                            setState(() {
                              schedule[index]['day'] = val ?? '';
                              scheduleErrors[index]['day'] = null;
                            });
                          },
                        ),
                        const SizedBox(height: TSizes.spaceBtwItems),

                        // Time picker
                        TextFormField(
                          controller: TextEditingController(text: item['time']),
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: appLocalizations.time,
                            prefixIcon: const Icon(Icons.access_time),
                            errorText: scheduleErrors[index]['time'],
                          ),
                          onTap: () async {
                            final TimeOfDay? picked = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (picked != null) {
                              setState(() {
                                schedule[index]['time'] = picked.format(context);
                                scheduleErrors[index]['time'] = null;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: TSizes.spaceBtwItems),

                        // Duration input
                        TextFormField(
                          initialValue: item['duration'],
                          decoration: InputDecoration(
                            labelText: appLocalizations.duration,
                            prefixIcon: const Icon(Iconsax.timer),
                            errorText: scheduleErrors[index]['duration'],
                          ),
                          onChanged: (val) {
                            schedule[index]['duration'] = val;
                            scheduleErrors[index]['duration'] = null;
                          },
                        ),

                        // Remove button
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            icon: const Icon(Iconsax.trash, color: Color(0xFFDF1E42)),
                            onPressed: () {
                              setState(() {
                                schedule.removeAt(index);
                                scheduleErrors.removeAt(index);
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
              const SizedBox(height: TSizes.spaceBtwItems),

              // Add new schedule row
              TextButton.icon(
                icon: const Icon(Iconsax.calendar_add),
                label: Text(appLocalizations.addSchedule),
                onPressed: () {
                  setState(() {
                    schedule.add({'day': '', 'time': '', 'duration': ''});
                    scheduleErrors.add({'day': null, 'time': null, 'duration': null});
                  });
                },
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
                    onPressed: () async {
                      if (_validate()) {
                        setState(() => _isSaving = true);

                        final success = await instructorClassService.updateFields(
                          widget.classId,
                          {'schedule': schedule},
                        );
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
              )
            ],
          ),
        ),
      ),
    );
  }
}

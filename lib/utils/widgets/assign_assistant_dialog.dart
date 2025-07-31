import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:onmat/controllers/class_assistant.dart';
import 'package:onmat/models/Instructor.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../constants/sizes.dart';

class AssignAssistantDialog extends StatefulWidget {
  final String classId;
  final List<Instructor> assistants;

  const AssignAssistantDialog({super.key, required this.classId, required this.assistants});

  @override
  State<AssignAssistantDialog> createState() => _AssignAssistantDialogState();
}

class _AssignAssistantDialogState extends State<AssignAssistantDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController assistant = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    assistant.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    final classAssistantService = Provider.of<ClassAssistantService>(context, listen: true);

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
                  appLocalizations.assignAssistant,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: TSizes.defaultSpace),

                TextFormField(
                  controller: assistant,
                  decoration: InputDecoration(
                    labelText: appLocalizations.assistantIdentifier,
                    hintText: appLocalizations.assistantHint,
                    prefixIcon: Icon(Iconsax.user),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? appLocalizations.required : null,
                ),
                const SizedBox(height: TSizes.spaceBtwItems),

                Column(
                  children: widget.assistants.map((instructor) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            "${instructor.firstName} ${instructor.lastName}",
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Iconsax.trash, color: Color(0xFFDF1E42)),
                          onPressed: () async {
                            final success = await classAssistantService.removeAssistantFromClass(
                              widget.classId,
                              instructor.userId
                            );

                            if (! success) {
                              Get.snackbar(
                                appLocalizations.error,
                                appLocalizations.errorMessage,
                                snackPosition: SnackPosition.BOTTOM,
                              );
                            }
                          },
                        ),
                      ],
                    );
                  }).toList(),
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

                          final success = await classAssistantService.assignAssistantToClass(
                              widget.classId,
                              assistant.text.trim()
                          );

                          if (! success) {
                            Get.snackbar(
                              appLocalizations.error,
                              appLocalizations.assistantNotFound,
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          }

                          setState(() => _isSaving = false);
                        }
                      },
                      child: _isSaving
                          ? const SizedBox(height: 15, width: 15, child: CircularProgressIndicator())
                          : Text(appLocalizations.assign),
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

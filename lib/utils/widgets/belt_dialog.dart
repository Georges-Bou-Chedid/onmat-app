import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:iconsax/iconsax.dart';
import 'package:uuid/uuid.dart';
import 'package:onmat/utils/constants/sizes.dart';

import '../../l10n/app_localizations.dart';
import '../../models/Belt.dart';

class BeltDialog extends StatefulWidget {
  final Belt? beltToEdit;
  final bool Function(Belt newBelt, List<Belt> existingBelts) hasOverlap;
  final List<Belt> existingBelts;

  const BeltDialog({
    Key? key,
    this.beltToEdit,
    required this.hasOverlap,
    required this.existingBelts,
  }) : super(key: key);

  @override
  _BeltDialogState createState() => _BeltDialogState();
}

class _BeltDialogState extends State<BeltDialog> {
  late RangeValues ageRange;
  late TextEditingController classesController;
  late TextEditingController maxStripesController;
  late Color selectedColor;
  Color? selectedColor2;

  @override
  void initState() {
    super.initState();
    if (widget.beltToEdit != null) {
      ageRange = RangeValues(widget.beltToEdit!.minAge.toDouble(), widget.beltToEdit!.maxAge.toDouble());
      classesController = TextEditingController(text: widget.beltToEdit!.classesPerBeltOrStripe.toString());
      maxStripesController = TextEditingController(text: widget.beltToEdit!.maxStripes.toString());
      selectedColor = widget.beltToEdit!.beltColor1;
      selectedColor2 = widget.beltToEdit!.beltColor2;
    } else {
      ageRange = const RangeValues(5, 15);
      classesController = TextEditingController();
      maxStripesController = TextEditingController(text: "0");
      selectedColor = Colors.white;
      selectedColor2 = null;
    }
  }

  // Dispose controllers
  @override
  void dispose() {
    classesController.dispose();
    maxStripesController.dispose();
    super.dispose();
  }

  // Build the dialog UI
  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(widget.beltToEdit != null ? appLocalizations.editBelt : appLocalizations.addBelt),
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

            /// Classes per BeltOrStripe
            TextField(
              controller: classesController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: appLocalizations.classesPerBeltOrStripe),
            ),

            const SizedBox(height: TSizes.inputFieldRadius),

            TextField(
              controller: maxStripesController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: appLocalizations.maxStripes),
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
            final maxStripes = int.tryParse(maxStripesController.text.trim());

            if (classes != null) {
              final newBelt = Belt(
                id: widget.beltToEdit?.id ?? Uuid().v4(), // Use existing ID for edit
                minAge: minAge,
                maxAge: maxAge,
                beltColor1: selectedColor,
                beltColor2: selectedColor2,
                classesPerBeltOrStripe: classes,
                maxStripes: maxStripes ?? 0,
                priority: widget.beltToEdit != null
                    ? widget.beltToEdit!.priority
                    : widget.existingBelts.length + 1,
              );
              // Check for overlaps with all other belts (excluding the one being edited)
              final otherBelts = widget.existingBelts.where((b) => b.id != newBelt.id).toList();
              if (widget.hasOverlap(newBelt, otherBelts)) {
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
    );
  }
}
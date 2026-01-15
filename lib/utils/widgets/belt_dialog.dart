import 'package:flutter/material.dart';
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
  late Color primaryBeltColor;
  Color? secondaryBeltColor;

  final Map<String, Color> beltColors = {
    "White": Colors.white,
    "Grey": Colors.grey,
    "Yellow": Colors.yellow,
    "Orange": Colors.orange,
    "Green": Colors.green,
    "Blue": Colors.blue,
    "Purple": Colors.purple,
    "Brown": Colors.brown,
    "Red": Colors.red,
    "Black": Colors.black,
  };

  @override
  void initState() {
    super.initState();
    if (widget.beltToEdit != null) {
      ageRange = RangeValues(widget.beltToEdit!.minAge.toDouble(), widget.beltToEdit!.maxAge.toDouble());
      classesController = TextEditingController(text: widget.beltToEdit!.classesPerBeltOrStripe.toString());
      maxStripesController = TextEditingController(text: widget.beltToEdit!.maxStripes.toString());
      primaryBeltColor = widget.beltToEdit!.beltColor1;
      secondaryBeltColor = widget.beltToEdit!.beltColor2;
    } else {
      ageRange = const RangeValues(5, 15);
      classesController = TextEditingController();
      maxStripesController = TextEditingController(text: "0");
      primaryBeltColor = Colors.white;
      secondaryBeltColor = null;
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

            _buildBeltPicker(appLocalizations.primaryBelt, primaryBeltColor, (c) => setState(() => primaryBeltColor = c), appLocalizations),
            const SizedBox(height: TSizes.inputFieldRadius),
            _buildBeltPicker(appLocalizations.secondaryBelt, secondaryBeltColor, (c) => setState(() => secondaryBeltColor = c), appLocalizations),
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
                beltColor1: primaryBeltColor,
                beltColor2: secondaryBeltColor,
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

  Widget _buildBeltPicker(String label, Color? value, Function(Color) onSet, AppLocalizations appLocalizations) {
    return InkWell(
      onTap: () => _showBeltColorPicker(context, onSet, appLocalizations),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 13), // Match label size
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), // Match dropdown padding
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // Pushes the arrow to the end
          children: [
            Row(
              children: [
                if (value != null)
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: value,
                      border: Border.all(width: 0.5, color: Colors.black),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                if (value != null) const SizedBox(width: 8),
                Text(
                  value == null ? appLocalizations.select : Belt.getColorName(value),
                  // Sync this style exactly with the dropdown
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const Icon(Icons.arrow_drop_down, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _showBeltColorPicker(BuildContext context, Function(Color) onChanged, AppLocalizations appLocalizations) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(appLocalizations.selectBeltColor),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: beltColors.entries.map((e) => ListTile(
              leading: Container(width: 20, height: 20, color: e.value),
              title: Text(e.key),
              onTap: () { onChanged(e.value); Navigator.pop(context); },
            )).toList(),
          ),
        ),
      ),
    );
  }
}
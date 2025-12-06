import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

import '../../../controllers/classItem/class_graduation.dart';
import '../../../controllers/student/class_student.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/Belt.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/widgets/circular_image.dart';
import 'class_details.dart';

class StudentProfileScreen extends StatefulWidget {
  final String studentId;
  final String classId;
  final bool isAssistant;

  const StudentProfileScreen({super.key, required this.studentId, required this.classId, required this.isAssistant});

  @override
  _StudentProfileScreenState createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  late ClassStudentService _classStudentService;
  late ClassGraduationService _classGraduationService;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _classStudentService = Provider.of<ClassStudentService>(context, listen: false);
    _classGraduationService = Provider.of<ClassGraduationService>(context, listen: false);
  }

  @override
  void dispose() {
    _classStudentService.cancelListener();
    _classGraduationService.cancelListener();
    super.dispose();
  }

  int calculateAge(String dobString) {
    try {
      // Parse: dd/MM/yyyy
      final parts = dobString.split('/');
      if (parts.length != 3) return 0;

      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);

      final birthDate = DateTime(year, month, day);
      final today = DateTime.now();

      int age = today.year - birthDate.year;

      // If birthday hasn’t happened yet this year, subtract 1
      if (today.month < birthDate.month ||
          (today.month == birthDate.month && today.day < birthDate.day)) {
        age--;
      }

      return age;
    } catch (e) {
      return 0; // fallback if parsing fails
    }
  }

  Belt? getNextBeltForStudent(int studentAge, List<Belt> belts, Color currentBelt1Color, Color? currentBelt2Color) {
    // Filter belts by age range
    final eligibleBelts = belts.where((belt) {
      return studentAge >= belt.minAge && studentAge <= belt.maxAge;
    }).toList();

    if (eligibleBelts.isEmpty) return null;

    // Sort by priority (lower number = higher rank)
    eligibleBelts.sort((a, b) => a.priority.compareTo(b.priority));

    // Skip belts that match student's current belt(s)
    for (var belt in eligibleBelts) {
      final beltColors = [belt.beltColor1, belt.beltColor2].whereType<Color>().toList();
      // Must contain current belt 1 color
      final matchesFirstColor = beltColors.contains(currentBelt1Color);

      // Must have a second color OR allow anything if current has none
      final validSecondColor = currentBelt2Color == null
          ? belt.beltColor2 != null   // next belt must introduce a new color2
          : beltColors.contains(currentBelt2Color);

      if (matchesFirstColor && validSecondColor) {
        return belt;
      }
    }

    // No next belt found
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;

    final classStudentService = Provider.of<ClassStudentService>(context, listen: true);
    final student = classStudentService.myStudents.firstWhereOrNull((s) => s.userId == widget.studentId);

    if (student == null) {
      Future.microtask(() => Get.back());
      return const SizedBox.shrink();
    }

    final studentAge = calculateAge(student.dob!);

    final classGraduationService = Provider.of<ClassGraduationService>(context, listen: true);
    final myGraduationBelts = classGraduationService.myGradutationBelts;

    final nextBelt = getNextBeltForStudent(
      studentAge,
      myGraduationBelts,
      student.belt1,
      student.belt2
    );

    return Scaffold(
      appBar: AppBar(
        title: Text("${student.firstName} ${student.lastName}"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Picture & Basic Info
            TCircularImage(
              image: "assets/images/settings/user.png",
              width: 50,
              height: 50,
              padding: 0,
            ),
            // CircleAvatar(
            //   radius: 50,
            //   backgroundImage: NetworkImage(student.profilePicture ?? ''),
            // ),
            const SizedBox(height: TSizes.spaceBtwItems),
            Text(
              "${student.firstName} ${student.lastName}",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(student.email ?? '', style: Theme.of(context).textTheme.bodyMedium),

            const SizedBox(height: TSizes.defaultSpace),

            // Info Grid
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(TSizes.spaceBtwItems),
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: 3,
                  children: [
                    _infoTile(appLocalizations.age, "$studentAge"),
                    _infoTile(appLocalizations.weight, "${student.weight} kg"),
                    _infoTile(appLocalizations.height, "${student.height} cm"),
                    _infoTile(appLocalizations.phoneNumber, student.phoneNumber ?? ''),
                    _infoTile(
                      appLocalizations.gender,
                      (student.gender ?? '').isEmpty
                          ? ''
                          : '${(student.gender![0].toUpperCase())}${student.gender!.substring(1).toLowerCase()}',
                    ),
                    _infoTile(appLocalizations.attendedToday, student.hasAttendanceToday ? "Yes" : "No"),
                  ],
                ),
              ),
            ),

            // Achievements Grid
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(TSizes.spaceBtwItems),
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: 2.2,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(appLocalizations.upcomingBelt, style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        if (nextBelt != null) ...[
                          Row(
                            children: [
                              Container(
                                width: 24,
                                height: 35,
                                decoration: BoxDecoration(
                                  color: nextBelt.beltColor1,
                                  border: Border.all(color: Colors.black, width: 1.5),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              if (nextBelt.beltColor2 != null) ...[
                                const SizedBox(width: 4),
                                Container(
                                  width: 24,
                                  height: 35,
                                  decoration: BoxDecoration(
                                    color: nextBelt.beltColor2,
                                    border: Border.all(color: Colors.black, width: 1.5),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ],
                    ),
                    _infoTile(
                      appLocalizations.remainingClasses,
                      nextBelt != null
                          ? "${student.classAttended} / ${nextBelt.classesPerBeltOrStripe}"
                          : "",
                      trailing: (nextBelt != null && student.classAttended >= nextBelt.classesPerBeltOrStripe)
                          ? const Icon(Iconsax.warning_2, color: Colors.orange)
                          : null,
                    ),
                    _infoTile(
                      appLocalizations.stripes,
                      nextBelt != null
                          ? "${student.stripes} / ${nextBelt.maxStripes}"
                          : "${student.stripes}",
                      trailing: (nextBelt != null && student.stripes >= nextBelt.maxStripes)
                          ? const Icon(Iconsax.warning_2, color: Colors.orange)
                          : null,
                    ),
                    _infoTile(appLocalizations.achievements, "")
                  ],
                ),
              ),
            ),

            const SizedBox(height: TSizes.defaultSpace),

            // Belt & Upgrade
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(TSizes.spaceBtwItems),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      appLocalizations.currentBelt,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Container(
                      width: 24,
                      height: 35,
                      decoration: BoxDecoration(
                        color: student.belt1,
                        border: Border.all(color: Colors.black, width: 1.5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    if (student.belt2 != null) ...[
                      const SizedBox(width: 4),
                      Container(
                        width: 24,
                        height: 35,
                        decoration: BoxDecoration(
                          color: student.belt2,
                          border: Border.all(color: Colors.black, width: 1.5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                    ElevatedButton(
                      onPressed: () {
                        // Show belt upgrade dialog
                      },
                      child: Text(appLocalizations.upgrade),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: TSizes.defaultSpace),

            // Progress
            Align(
              alignment: Alignment.centerLeft,
              child: Text(appLocalizations.progressBar,
                  style: Theme.of(context).textTheme.titleMedium),
            ),
            const SizedBox(height: TSizes.spaceBtwItems),

            _progressTile(
              appLocalizations.classesAttended,
              student.classAttended,
              nextBelt != null
                  ? nextBelt.classesPerBeltOrStripe - student.classAttended
                  : 0,
              appLocalizations
            ),
            const SizedBox(height: TSizes.spaceBtwItems),

            Wrap(
              spacing: TSizes.borderRadiusLg,
              runSpacing: TSizes.borderRadiusLg,
              children: [
                ElevatedButton.icon(
                  icon: Icon(Iconsax.copy_success, size: TSizes.iconSm),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    await showDialog(
                      context: context,
                      barrierDismissible: true,
                      builder: (context) => AlertDialog(
                        title: Text(appLocalizations.removeFromClass),
                        content: Text(appLocalizations.removeFromClassText("${student.firstName} ${student.lastName}")),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: Text(appLocalizations.cancel),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: Text(appLocalizations.remove),
                          ),
                        ],
                      ),
                    ).then((confirmed) async {
                      if (confirmed == true) {
                        final success = await classStudentService.removeStudentFromClass(
                            widget.classId,
                            student.userId!
                        );

                        if (! success) {
                          Get.snackbar(
                            appLocalizations.error,
                            appLocalizations.errorMessage,
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        }
                      }
                    });
                  },
                  label: Text(appLocalizations.addAchievemnt),
                ),
                ElevatedButton.icon(
                  icon: Icon(Iconsax.profile_remove, size: TSizes.iconSm),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    await showDialog(
                      context: context,
                      barrierDismissible: true,
                      builder: (context) => AlertDialog(
                        title: Text(appLocalizations.removeFromClass),
                        content: Text(appLocalizations.removeFromClassText("${student.firstName} ${student.lastName}")),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: Text(appLocalizations.cancel),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: Text(appLocalizations.remove),
                          ),
                        ],
                      ),
                    ).then((confirmed) async {
                      if (confirmed == true) {
                        final success = await classStudentService.removeStudentFromClass(
                            widget.classId,
                            student.userId!
                        );

                        if (! success) {
                          Get.snackbar(
                            appLocalizations.error,
                            appLocalizations.errorMessage,
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        }
                      }
                    });
                  },
                  label: Text(appLocalizations.remove),
                ),
              ]
            ),
            const SizedBox(height: TSizes.lg),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(String label, String value, {Widget? trailing}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        Row(
          children: [
            Text(value),
            const SizedBox(width: TSizes.spaceBtwItems),
            if (trailing != null) trailing,
          ],
        ),
      ],
    );
  }

  Widget _progressTile(String label, int attended, int left, AppLocalizations appLocalization) {
    final totalRequired = attended + left; // classes needed for current belt
    final cappedAttended = attended > totalRequired ? totalRequired : attended;
    final progress = totalRequired > 0 ? (cappedAttended / totalRequired) : 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label with progress count
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
              Text("$attended / $totalRequired"),
            ],
          ),
          const SizedBox(height: 6),

          // Progress bar capped at 100%
          LinearProgressIndicator(
            value: progress, // stays at 1.0 max
            backgroundColor: Colors.grey.shade300,
            color: Color(0xFFDF1E42), // 🔴 red for progress
            minHeight: 10,
          ),

          // Show how many classes left if requirement not met
          if (attended < totalRequired)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                "$left ${appLocalization.classesLeft}",
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ),

          // Show extra info if they passed requirement but no upgrade yet
          if (attended > totalRequired)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                "+${attended - totalRequired} ${appLocalization.extraClasses}",
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ),
        ],
      ),
    );
  }
}

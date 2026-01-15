import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

import '../../../controllers/classItem/class_graduation.dart';
import '../../../controllers/student/class_student.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/Belt.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/helpers/helper_functions.dart';
import '../../../utils/widgets/circular_image.dart';

class StudentProfileScreen extends StatefulWidget {
  final String studentId;
  final String classId;
  final bool isAssistant;
  final bool showInstructorFeatures;

  const StudentProfileScreen({
    super.key,
    required this.studentId,
    required this.classId,
    required this.isAssistant,
    required this.showInstructorFeatures
  });

  @override
  _StudentProfileScreenState createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  final Color primaryBrandColor = const Color(0xFFDF1E42);
  late ClassStudentService _classStudentService;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _classStudentService = Provider.of<ClassStudentService>(context, listen: false);
  }

  int calculateAge(String dobString) {
    try {
      final parts = dobString.split('/');
      if (parts.length != 3) return 0;
      final birthDate = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
      final today = DateTime.now();
      int age = today.year - birthDate.year;
      if (today.month < birthDate.month || (today.month == birthDate.month && today.day < birthDate.day)) age--;
      return age;
    } catch (e) {
      return 0;
    }
  }

  Belt? getNextBeltForStudent(int studentAge, List<Belt> belts, Color currentBelt1Color, Color? currentBelt2Color) {
    // 1. Filter by age
    final eligibleBelts = belts.where((belt) {
      return studentAge >= belt.minAge && studentAge <= belt.maxAge;
    }).toList();

    if (eligibleBelts.isEmpty) return null;

    // 2. Sort by priority (e.g., Priority 1 is Black, Priority 10 is White)
    // We want to find the belt that is "one step better" than current
    eligibleBelts.sort((a, b) => a.priority.compareTo(b.priority));

    // 3. Find the current belt's priority index
    int currentPriority = 999; // Default low rank
    for (var belt in eligibleBelts) {
      if (belt.beltColor1 == currentBelt1Color && belt.beltColor2 == currentBelt2Color) {
        currentPriority = belt.priority;
        break;
      }
    }

    // 4. Return the belt that has the next highest priority (immediately lower number than current)
    try {
      // We look for the belt whose priority is less than currentPriority
      // but is the largest among those smaller values (the immediate next step)
      return eligibleBelts.lastWhere((belt) => belt.priority < currentPriority);
    } catch (e) {
      // If no higher belt is found in that age range
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    final dark = THelperFunctions.isDarkMode(context);
    final classStudentService = Provider.of<ClassStudentService>(context);
    final student = classStudentService.myStudents.firstWhereOrNull((s) => s.userId == widget.studentId);

    if (student == null) {
      Future.microtask(() => Get.back());
      return const SizedBox.shrink();
    }

    final studentAge = calculateAge(student.dob!);
    final myGraduationBelts = Provider.of<ClassGraduationService>(context).myGradutationBelts;
    final nextBelt = getNextBeltForStudent(studentAge, myGraduationBelts, student.belt1, student.belt2);

    return Scaffold(
      appBar: AppBar(
        title: Text("Student Profile"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          children: [
            /// 1. PROFILE HEADER
            Center(
              child: Column(
                children: [
                  TCircularImage(
                    image:  "assets/images/settings/user.png",
                    // isNetworkImage: (student.profilePicture != null && student.profilePicture!.isNotEmpty),
                    width: 100,
                    height: 100,
                    padding: 0,
                  ),
                  const SizedBox(height: TSizes.spaceBtwItems),
                  Text("${student.firstName} ${student.lastName}", style: Theme.of(context).textTheme.headlineSmall),
                  Text(student.email ?? '', style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            ),

            const SizedBox(height: TSizes.spaceBtwSections),

            /// 2. PERSONAL INFO GRID
            _buildSectionContainer(
              dark,
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 2.8,
                children: [
                  _infoTile(appLocalizations.age, "$studentAge"),
                  _infoTile(appLocalizations.weight, "${student.weight} kg"),
                  _infoTile(appLocalizations.height, "${student.height} cm"),
                  _infoTile(appLocalizations.gender, student.gender?.capitalizeFirst ?? 'N/A'),
                ],
              ),
            ),

            const SizedBox(height: TSizes.spaceBtwItems),

            /// 3. GRADUATION & BELT STATUS
            _buildSectionContainer(
              dark,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(appLocalizations.currentBelt, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
                          const SizedBox(height: 8),
                          _buildBeltVisual(student.belt1, student.belt2),
                        ],
                      ),
                      if (widget.showInstructorFeatures)
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryBrandColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () => _handleUpgrade(student, nextBelt, classStudentService, appLocalizations),
                          child: Text(appLocalizations.upgrade),
                        ),
                    ],
                  ),
                  const Divider(height: 32),

                  Row(
                    children: [
                      // Upcoming Belt
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(appLocalizations.upcomingBelt, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                            const SizedBox(height: 8),
                            if (nextBelt != null)
                              _buildBeltVisual(nextBelt.beltColor1, nextBelt.beltColor2)
                            else
                              const Text("—", style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      // Stripes
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(appLocalizations.stripes, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Text(
                                  nextBelt != null ? "${student.stripes} / ${nextBelt.maxStripes}" : "${student.stripes}",
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                if (nextBelt != null && student.stripes >= nextBelt.maxStripes)
                                  const Padding(
                                    padding: EdgeInsets.only(left: 8.0),
                                    child: Icon(Iconsax.warning_2, color: Colors.orange, size: 18),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  _progressTile(
                      appLocalizations.classesAttended,
                      student.classAttended,
                      nextBelt?.classesPerBeltOrStripe ?? 0,
                      appLocalizations,
                      showWarning: (nextBelt != null && student.classAttended >= nextBelt.classesPerBeltOrStripe)
                  ),
                ],
              ),
            ),

            const SizedBox(height: TSizes.spaceBtwItems),

            /// 4. ACHIEVEMENTS SECTION
            _buildSectionContainer(
              dark,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(appLocalizations.achievements, style: const TextStyle(fontWeight: FontWeight.bold)),
                      IconButton(
                        onPressed: () {}, // Add achievement logic
                        icon: Icon(Iconsax.add_square, color: primaryBrandColor),
                      ),
                    ],
                  ),
                  // if (student.achievements == null || student.achievements!.isEmpty)
                  //   Padding(
                  //     padding: const EdgeInsets.symmetric(vertical: 8.0),
                  //     child: Text(
                  //         "No achievements recorded yet.",
                  //         style: TextStyle(color: Colors.grey[500], fontSize: 13, fontStyle: FontStyle.italic)
                  //     ),
                  //   )
                  // else
                  // // Example Achievement List
                  //   ListView.builder(
                  //     shrinkWrap: true,
                  //     physics: const NeverScrollableScrollPhysics(),
                  //     itemCount: student.achievements?.length ?? 0,
                  //     itemBuilder: (context, index) => ListTile(
                  //       contentPadding: EdgeInsets.zero,
                  //       leading: const Icon(Iconsax.medal_star, color: Colors.amber),
                  //       title: Text(student.achievements![index]),
                  //     ),
                  //   ),
                ],
              ),
            ),

            const SizedBox(height: TSizes.spaceBtwSections),

            /// 5. DANGER ZONE
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                    foregroundColor: primaryBrandColor,
                    side: BorderSide(color: primaryBrandColor)
                ),
                icon: const Icon(Iconsax.profile_remove),
                onPressed: () => _confirmRemoval(student, classStudentService, appLocalizations),
                label: Text(appLocalizations.remove),
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwSections),
          ],
        ),
      ),
    );
  }

  /// HELPER WIDGETS
  Widget _buildSectionContainer(bool dark, {required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: dark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: child,
    );
  }

  Widget _buildBeltVisual(Color c1, Color? c2) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 25, height: 40,
          decoration: BoxDecoration(color: c1, border: Border.all(width: 1.5, color: Colors.black), borderRadius: BorderRadius.circular(4)),
        ),
        if (c2 != null) ...[
          const SizedBox(width: 4),
          Container(
            width: 25, height: 40,
            decoration: BoxDecoration(color: c2, border: Border.all(width: 1.5, color: Colors.black), borderRadius: BorderRadius.circular(4)),
          ),
        ]
      ],
    );
  }

  Widget _infoTile(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _progressTile(String label, int attended, int required, AppLocalizations l10n, {bool showWarning = false}) {
    final progress = required > 0 ? (attended / required).clamp(0.0, 1.0) : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
                if (showWarning) const Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Icon(Iconsax.warning_2, color: Colors.orange, size: 16),
                ),
              ],
            ),
            Text("$attended / $required"),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[200],
          color: primaryBrandColor,
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  void _handleUpgrade(student, Belt? nextBelt, service, l10n) {
    if (nextBelt == null) return;
    bool isStripeUpgrade = student.stripes < nextBelt.maxStripes;

    Get.defaultDialog(
        title: l10n.upgrade,
        middleText: isStripeUpgrade
            ? "Add a stripe to ${student.firstName}?"
            : "Promote ${student.firstName} to the next belt?",
        textConfirm: l10n.confirm,
        confirmTextColor: Colors.white,
        buttonColor: primaryBrandColor,
        onConfirm: () async {
          if (isStripeUpgrade) {
            await service.updateStudentStripes(widget.classId, student.userId!, student.stripes + 1);
          } else {
            await service.upgradeStudentBelt(widget.classId, student.userId!, nextBelt.beltColor1, nextBelt.beltColor2);
          }
          Get.back();
        }
    );
  }

  void _confirmRemoval(student, service, l10n) {
    Get.defaultDialog(
        title: l10n.removeFromClass,
        middleText: l10n.removeFromClassText("${student.firstName} ${student.lastName}"),
        textConfirm: l10n.remove,
        confirmTextColor: Colors.white,
        buttonColor: primaryBrandColor,
        onConfirm: () async {
          await service.removeStudentFromClass(widget.classId, student.userId!);
          Get.back();
          Get.back();
        }
    );
  }
}
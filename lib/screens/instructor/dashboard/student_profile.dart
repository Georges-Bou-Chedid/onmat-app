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

  /// Detects if the student's current belt is missing from the curriculum
  bool isStudentRankLost(int studentAge, List<Belt> belts, Color c1, Color? c2) {
    // If they are a basic white belt, they aren't "lost", they are just new.
    if (c1.value == Colors.white.value && c2 == null) return false;

    final eligible = belts.where((b) => studentAge >= b.minAge && studentAge <= b.maxAge).toList();

    // If we can't find their current belt colors in the system, they are lost.
    return !eligible.any((b) => b.beltColor1.value == c1.value && b.beltColor2?.value == c2?.value);
  }

  Belt? getNextBeltForStudent(int studentAge, List<Belt> belts, Color currentBelt1Color, Color? currentBelt2Color) {
    final eligible = belts.where((b) => studentAge >= b.minAge && studentAge <= b.maxAge).toList();
    if (eligible.isEmpty) return null;

    eligible.sort((a, b) => a.priority.compareTo(b.priority));

    final currentIndex = eligible.indexWhere((b) =>
    b.beltColor1.value == currentBelt1Color.value &&
        b.beltColor2?.value == currentBelt2Color?.value);

    if (currentIndex == -1) {
      if (currentBelt1Color.value == Colors.white.value && currentBelt2Color == null) {
        return eligible.first;
      }
      return null;
    } else if (currentIndex < eligible.length - 1) {
      return eligible[currentIndex + 1];
    }
    return null;
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
    final isLost = isStudentRankLost(studentAge, myGraduationBelts, student.belt1, student.belt2);

    return Scaffold(
      appBar: AppBar(title: Text(appLocalizations.studentProfile), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          children: [
            /// 1. PROFILE HEADER
            Center(
              child: Column(
                children: [
                  TCircularImage(
                    // Check if the student in the class list has a profile picture URL
                    image: (student.profilePicture != null && student.profilePicture!.isNotEmpty)
                        ? student.profilePicture!
                        : "assets/images/settings/user.png",
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

            /// 2. SYNC WARNING (If rank is lost)
            if (widget.showInstructorFeatures && isLost) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(TSizes.md),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.withOpacity(0.5)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Iconsax.warning_2, color: Colors.orange),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            appLocalizations.rankMismatch ?? "Rank Mismatch Detected",
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      appLocalizations.rankMismatchDesc ?? "This student's belt is not in the current curriculum. Sync to fix.",
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
                        onPressed: () => _showSyncMenu(student, myGraduationBelts, classStudentService, appLocalizations),
                        child: Text(appLocalizations.syncRank ?? "Sync Student Rank"),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: TSizes.spaceBtwItems),
            ],

            /// 3. PERSONAL INFO
            _buildSectionContainer(dark,
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
                  _infoTile(appLocalizations.attendedToday, student.hasAttendanceToday ? 'Yes' : 'No'),
                ],
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwItems),

            /// 4. GRADUATION & BELT STATUS
            _buildSectionContainer(dark,
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
                      if (widget.showInstructorFeatures && !isLost)
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: primaryBrandColor),
                          onPressed: () => _handleUpgrade(student, nextBelt, classStudentService, dark, appLocalizations),
                          child: Text(appLocalizations.upgrade),
                        ),
                    ],
                  ),
                  const Divider(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(appLocalizations.upcomingBelt, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                            const SizedBox(height: 8),
                            if (nextBelt != null) _buildBeltVisual(nextBelt.beltColor1, nextBelt.beltColor2)
                            else const Text("—", style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(appLocalizations.stripes, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                            const SizedBox(height: 8),
                            Text("${student.stripes}${nextBelt != null ? ' / ${nextBelt.maxStripes}' : ''}",
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
            const SizedBox(height: TSizes.spaceBtwSections),

            /// 5. DANGER ZONE
            if (widget.showInstructorFeatures)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(foregroundColor: primaryBrandColor, side: BorderSide(color: primaryBrandColor)),
                  icon: const Icon(Iconsax.profile_remove),
                  onPressed: () => _confirmRemoval(student, classStudentService, appLocalizations),
                  label: Text(appLocalizations.remove),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// UI Helper Methods
  void _showSyncMenu(student, List<Belt> belts, service, l10n) {
    // 1. Calculate student age (using your existing helper)
    final studentAge = calculateAge(student.dob!);

    // 2. Filter belts to only show those valid for the student's age
    final eligibleBelts = belts.where((b) =>
    studentAge >= b.minAge && studentAge <= b.maxAge
    ).toList();

    // 3. Sort them by priority so they appear in order
    eligibleBelts.sort((a, b) => a.priority.compareTo(b.priority));

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(TSizes.md),
        decoration: BoxDecoration(
          color: THelperFunctions.isDarkMode(context) ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag Handle
            Container(
              width: 40, height: 4, margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
            ),

            Text(l10n.selectCorrectRank ?? "Select Correct Rank", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 16),

            // Use the filtered list here
            if (eligibleBelts.isEmpty)
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(l10n.noBeltsForAge ?? "No curriculum found for this age group."),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: eligibleBelts.length,
                  itemBuilder: (context, index) {
                    final belt = eligibleBelts[index];
                    return ListTile(
                      leading: _buildBeltVisual(belt.beltColor1, belt.beltColor2),
                      title: Text("${l10n.rank ?? 'Rank'} ${belt.priority}"),
                      subtitle: Text("${belt.minAge}-${belt.maxAge} ${l10n.years ?? 'years'}"),
                      onTap: () async {
                        await service.upgradeStudentBelt(
                            widget.classId,
                            student.userId!,
                            belt.beltColor1,
                            belt.beltColor2
                        );
                        Get.back();
                      },
                    );
                  },
                ),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

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

  void _handleUpgrade(student, Belt? nextBelt, service, dark, l10n) {
    final String studentName = "${student.firstName} ${student.lastName}".trim();

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(TSizes.md),
        decoration: BoxDecoration(
          color: THelperFunctions.isDarkMode(context) ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 20), decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
            Text(l10n.upgrade, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: TSizes.spaceBtwSections),
            ListTile(
              leading: const Icon(Iconsax.medal_star, color: Colors.orange),
              title: Text(l10n.addStripe ?? "Add Stripe"),
              subtitle: Text("${l10n.currentStripes ?? 'Current'}: ${student.stripes}"),
              onTap: () async {
                await service.updateStudentStripes(widget.classId, student.userId!, studentName, student.stripes + 1);
                Get.back();
              },
            ),
            const Divider(),
            if (nextBelt != null)
              ListTile(
                leading: const Icon(Iconsax.award, color: Color(0xFFDF1E42)),
                title: Text(l10n.promoteToNextBelt ?? "Promote to Next Belt"),
                subtitle: Text(l10n.promotionWarning ?? "Resets stripes and attendance"),
                onTap: () {
                  Get.back(); // Close the BottomSheet first

                  showDialog<bool>(
                    context: context,
                    barrierDismissible: true,
                    builder: (context) => AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide.none,
                      ),
                      title: Text(l10n.confirmPromotion ?? "Confirm Promotion", style: const TextStyle(fontWeight: FontWeight.bold)),
                      content: Text("${l10n.promoteConfirmText ?? 'Are you sure you want to promote'} ${student.firstName}?"),
                      actions: [
                        // Cancel Button: Simple TextButton
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: Text(l10n.cancel, style: TextStyle(color: dark ? Colors.white70 : Colors.black87)),
                        ),
                        // Confirm Button: Branded ElevatedButton
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryBrandColor,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () => Navigator.of(context).pop(true),
                          child: Text(l10n.confirm, style: const TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ).then((confirmed) async {
                    if (confirmed == true && nextBelt != null) {
                      await service.upgradeStudentBelt(
                          widget.classId,
                          student.userId!,
                          studentName,
                          nextBelt.beltColor1,
                          nextBelt.beltColor2
                      );
                    }
                  });
                },
              ),
            const SizedBox(height: TSizes.spaceBtwSections),
          ],
        ),
      ),
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
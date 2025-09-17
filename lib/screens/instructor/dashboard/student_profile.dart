import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../controllers/classItem/class_graduation.dart';
import '../../../controllers/student/class_student.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/Belt.dart';
import '../../../utils/widgets/circular_image.dart';

class StudentProfileScreen extends StatefulWidget {
  final String studentId;
  final String classId;

  const StudentProfileScreen({super.key, required this.studentId, required this.classId});

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

  Belt? getNextBeltForStudent(int studentAge, List<Belt> belts) {
    // Filter belts by age range
    final eligibleBelts = belts.where((belt) {
      return studentAge >= belt.minAge && studentAge <= belt.maxAge;
    }).toList();

    if (eligibleBelts.isEmpty) return null;

    // Sort by priority (lower number = higher rank)
    eligibleBelts.sort((a, b) => a.priority.compareTo(b.priority));

    return eligibleBelts.first;
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;

    final classStudentService = Provider.of<ClassStudentService>(context, listen: true);
    final student = classStudentService.myStudents.firstWhereOrNull((s) => s.userId == widget.studentId);

    final studentAge = calculateAge(student!.dob!);

    final classGraduationService = Provider.of<ClassGraduationService>(context, listen: true);
    final myGraduationBelts = classGraduationService.myGradutationBelts;

    final nextBelt = getNextBeltForStudent(studentAge, myGraduationBelts);

    final beltColors = {
      "White": Colors.white,
      "Blue": Colors.blue,
      "Purple": Colors.purple,
      "Brown": Colors.brown,
      "Black": Colors.black,
    };

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
            const SizedBox(height: 12),
            Text(
              "${student.firstName} ${student.lastName}",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(student.email ?? '', style: Theme.of(context).textTheme.bodyMedium),

            const SizedBox(height: 20),

            // Info Grid
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: 3.5,
                  children: [
                    _infoTile(appLocalizations.age, "$studentAge"),
                    _infoTile(appLocalizations.weight, "${student.weight} kg"),
                    _infoTile(appLocalizations.height, "${student.height} cm"),
                    _infoTile(appLocalizations.phoneNumber, student.phoneNumber ?? ''),
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
                padding: const EdgeInsets.all(16),
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: 3.5,
                  children: [
                    _infoTile("Next Belt", Belt.getColorName(nextBelt!.beltColor1)),
                    _infoTile("Classes Left", "${student.classAttended} / ${nextBelt.classesPerBeltOrStripe}"),
                    _infoTile("Achievements", ""),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Belt & Upgrade
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      height: 24,
                      width: 60,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Current Belt: ${'Unknown'}",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Show belt upgrade dialog
                      },
                      child: const Text("Upgrade"),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Progress
            Align(
              alignment: Alignment.centerLeft,
              child: Text("Progress in This Class",
                  style: Theme.of(context).textTheme.titleMedium),
            ),
            const SizedBox(height: 10),

            _progressTile("Classes", 0.7),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(value),
      ],
    );
  }

  Widget _progressTile(String label, double value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: value,
            backgroundColor: Colors.grey.shade300,
            color: Colors.green,
            minHeight: 8,
          ),
        ],
      ),
    );
  }
}

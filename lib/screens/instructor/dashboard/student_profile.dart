import 'package:flutter/material.dart';

import '../../../models/Student.dart';
import '../../../utils/widgets/circular_image.dart';

class StudentProfileScreen extends StatelessWidget {
  final Student student;

  const StudentProfileScreen({Key? key, required this.student}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                    _infoTile("Age", "${student.dob}"),
                    _infoTile("Weight", "${student.weight} kg"),
                    _infoTile("Height", "${student.height} cm"),
                    _infoTile("Phone", student.phoneNumber ?? ''),
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

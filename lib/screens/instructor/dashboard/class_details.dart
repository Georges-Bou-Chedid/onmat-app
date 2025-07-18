import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../l10n/app_localizations.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/widgets/background_image_header_container.dart';
import '../start.dart';

class ClassDetailsScreen extends StatefulWidget {
  const ClassDetailsScreen({super.key});

  @override
  _ClassDetailsScreenState createState() => _ClassDetailsScreenState();
}

class _ClassDetailsScreenState extends State<ClassDetailsScreen> {
  late AppLocalizations appLocalizations;

  @override
  Widget build(BuildContext context) {
    appLocalizations = AppLocalizations.of(context)!;

    // You can replace these with real data models
    final className = "Advanced Taekwondo";
    final classType = "Martial Arts";
    final location = "Beirut";
    final country = "Lebanon";
    final schedule = [
      {"day": "Monday", "time": "2:00 PM", "duration": "2h"},
      {"day": "Wednesday", "time": "2:00 PM", "duration": "2h"},
      {"day": "Friday", "time": "2:00 PM", "duration": "2h"},
    ];

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            /// -- Header
            TBackgroundImageHeaderContainer(
              image: 'assets/images/class_details_background.jpg',
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
                        className,
                        style: Theme.of(context).textTheme.headlineSmall!.apply(color: Colors.white)
                    ),
                  ),
                  const SizedBox(height: TSizes.appBarHeight)
                ],
              ),
            ),

            /// CLASS INFO
            Padding(
              padding: const EdgeInsets.all(TSizes.spaceBtwItems),
              child: Column(
                children: [
                  _buildSectionTitle(context, "Class Information"),
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _infoRow("Type", classType),
                          _infoRow("Location", "$location, $country"),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  /// CLASS SCHEDULE
                  _buildSectionTitle(context, "Weekly Schedule"),
                  ...schedule.map((s) => ListTile(
                    leading: Icon(Iconsax.clock, color: Theme.of(context).primaryColor),
                    title: Text("${s['day']}"),
                    subtitle: Text("${s['time']} • ${s['duration']}"),
                  )),
                  const SizedBox(height: 20),

                  /// ACTIONS
                  _buildSectionTitle(context, "Actions"),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _actionButton(context, Iconsax.edit, "Edit Class", onTap: () {}),
                      _actionButton(context, Iconsax.calendar, "Reschedule", onTap: () {}),
                      _actionButton(context, Iconsax.user_add, "Assign Assistants", onTap: () {}),
                    ],
                  ),
                  const SizedBox(height: 30),

                  /// STUDENT LIST
                  _buildSectionTitle(context, "Students"),
                  TextField(
                    decoration: InputDecoration(
                      hintText: "Search students...",
                      prefixIcon: Icon(Iconsax.search_normal),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: 5, // replace with studentList.length
                    separatorBuilder: (_, __) => Divider(),
                    itemBuilder: (_, index) => ListTile(
                      leading: CircleAvatar(child: Text("S${index + 1}")),
                      title: Text("Student Name $index"),
                      subtitle: Text("student$index@email.com"),
                      trailing: Icon(Iconsax.arrow_right_3),
                    ),
                  ),
                  const SizedBox(height: 30),

                  /// QR CODE
                  _buildSectionTitle(context, "Class QR Code"),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Image.network(
                        'https://api.qrserver.com/v1/create-qr-code/?data=class_id_123&size=200x200',
                        height: 200,
                        width: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// --- COMPONENT HELPERS ---

  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text("$title: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _actionButton(BuildContext context, IconData icon, String label, {required VoidCallback onTap}) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

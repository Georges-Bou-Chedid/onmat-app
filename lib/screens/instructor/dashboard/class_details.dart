import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:onmat/models/Instructor.dart';
import 'package:provider/provider.dart';
import 'package:country_picker/country_picker.dart';

import '../../../controllers/class_assistant.dart';
import '../../../controllers/instructor.dart';
import '../../../controllers/instructor_class.dart';
import '../../../l10n/app_localizations.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/widgets/assign_assistant_dialog.dart';
import '../../../utils/widgets/background_image_header_container.dart';
import '../../../utils/widgets/edit_class_dialog.dart';
import '../../../utils/widgets/reschedule_dialog.dart';
import '../start.dart';

class ClassDetailsScreen extends StatefulWidget {
  final String classId;
  final bool isAssistant;
  const ClassDetailsScreen({super.key, required this.classId, required this.isAssistant});

  @override
  _ClassDetailsScreenState createState() => _ClassDetailsScreenState();
}

class _ClassDetailsScreenState extends State<ClassDetailsScreen> {
  late Instructor? instructor;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    /// Fetch classes
    final instructorClassService = Provider.of<InstructorClassService>(context, listen: true);
    final classItem = widget.isAssistant
        ? instructorClassService.assistantClasses.firstWhereOrNull((cl) => cl.id == widget.classId)
        : instructorClassService.ownerClasses.firstWhereOrNull((cl) => cl.id == widget.classId);

    /// Fetch Assistants
    final classAssistantService = Provider.of<ClassAssistantService>(context, listen: true);
    final myAssistants = classAssistantService.myAssistants;

    /// Fetch Owner
    if (widget.isAssistant) {
      instructor = instructorClassService.classOwner;
    } else {
      InstructorService instructorService = Provider.of<InstructorService>(context, listen: true);
      instructor = instructorService.instructor;
    }

    final appLocalizations = AppLocalizations.of(context)!;

    if (classItem == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(appLocalizations.classNotFound)),
      );
    }

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
                        classItem.className ?? '',
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
                  _buildSectionTitle(context, appLocalizations.classInfo),
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _infoRow(appLocalizations.instructor, "${instructor!.firstName} ${instructor!.lastName}"),
                          _infoRow(appLocalizations.type, classItem.classType!),
                          _infoRow(appLocalizations.location, "${classItem.location}, ${Country.parse(classItem.country ?? "LB").name}"),
                          if (myAssistants.isNotEmpty)
                          _infoRow(
                            appLocalizations.assistants,
                            myAssistants.map((a) => "${a.firstName} ${a.lastName}").join(', ')
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  /// CLASS SCHEDULE
                  _buildSectionTitle(context, appLocalizations.weeklySchedule),
                  ...classItem.schedule!.map((s) => ListTile(
                    leading: Icon(Iconsax.clock, color: Theme.of(context).primaryColor),
                    title: Text("${s['day']}"),
                    subtitle: Text("${s['time']} • ${s['duration']}"),
                  )),
                  const SizedBox(height: 20),

                  /// ACTIONS
                  _buildSectionTitle(context, appLocalizations.actions),
                  Wrap(
                    spacing: TSizes.borderRadiusLg,
                    runSpacing: TSizes.borderRadiusLg,
                    children: [
                      _actionButton(context, Iconsax.edit, appLocalizations.editClass, onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => EditClassDialog(classItem: classItem),
                        );
                      }),
                      _actionButton(context, Iconsax.calendar, appLocalizations.reschedule, onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => RescheduleDialog(
                            classId: classItem.id,
                            initialSchedule: List<Map<String, String>>.from(classItem.schedule ?? [])
                          ),
                        );
                      }),
                      if (! widget.isAssistant)
                      _actionButton(context, Iconsax.user_add, appLocalizations.assignAssistant, onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => AssignAssistantDialog(classId: classItem.id, assistants: myAssistants),
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 30),

                  /// STUDENT LIST
                  _buildSectionTitle(context, appLocalizations.students),
                  TextField(
                    decoration: InputDecoration(
                      hintText: appLocalizations.searchStudents,
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
                  _buildSectionTitle(context, appLocalizations.classQrCode),
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

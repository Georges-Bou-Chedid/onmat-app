import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:onmat/models/Instructor.dart';
import 'package:provider/provider.dart';
import 'package:country_picker/country_picker.dart';

import '../../../controllers/instructor/class_assistant.dart';
import '../../../controllers/instructor/instructor.dart';
import '../../../controllers/instructor/instructor_class.dart';
import '../../../controllers/student/class_student.dart';
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
  final TextEditingController _searchController = TextEditingController();
  late Instructor? instructor;
  late FocusNode _searchFocusNode;
  String _searchQuery = '';

  late ClassAssistantService _classAssistantService;
  late ClassStudentService _classStudentService;

  @override
  void initState() {
    super.initState();
    _searchFocusNode = FocusNode();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Safely get providers once here, where context is stable
    _classAssistantService = Provider.of<ClassAssistantService>(context, listen: false);
    _classStudentService = Provider.of<ClassStudentService>(context, listen: false);
  }

  @override
  void dispose() {
    _classAssistantService.cancelListener();
    _classStudentService.cancelListener();

    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// Save class
    final instructorClassService = Provider.of<InstructorClassService>(context, listen: true);
    final classItem = widget.isAssistant
        ? instructorClassService.assistantClasses.firstWhereOrNull((cl) => cl.id == widget.classId)
        : instructorClassService.ownerClasses.firstWhereOrNull((cl) => cl.id == widget.classId);

    /// Save Assistants
    final classAssistantService = Provider.of<ClassAssistantService>(context, listen: true);
    final myAssistants = classAssistantService.myAssistants;

    /// Save Owner
    if (widget.isAssistant) {
      instructor = instructorClassService.classOwner;
    } else {
      InstructorService instructorService = Provider.of<InstructorService>(context, listen: true);
      instructor = instructorService.instructor;
    }

    /// Save Students
    final classStudentService = Provider.of<ClassStudentService>(context, listen: true);
    final myStudents = classStudentService.myStudents;
    final filteredStudents = myStudents.where((cs) {
      final query = _searchQuery.trim().toLowerCase();
      return cs.firstName?.toLowerCase().contains(query) == true ||
          cs.lastName?.toLowerCase().contains(query) == true ||
          cs.email?.toLowerCase().contains(query) == true;
    }).toList();

    final appLocalizations = AppLocalizations.of(context)!;

    if (classItem == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(appLocalizations.classNotFound)),
      );
    }

    return GestureDetector(
      onTap: () => _searchFocusNode.unfocus(),
      child: Scaffold(
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(TSizes.iconXs)),
                      child: Padding(
                        padding: const EdgeInsets.all(TSizes.md),
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
                    const SizedBox(height: TSizes.defaultSpace),

                    /// CLASS SCHEDULE
                    _buildSectionTitle(context, appLocalizations.weeklySchedule),
                    ...classItem.schedule!.map((s) => ListTile(
                      leading: Icon(Iconsax.clock, color: Theme.of(context).primaryColor),
                      title: Text("${s['day']}"),
                      subtitle: Text("${s['time']} • ${s['duration']}"),
                    )),
                    const SizedBox(height: TSizes.defaultSpace),

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
                            builder: (_) => AssignAssistantDialog(classId: classItem.id),
                          );
                        }),
                        if (! widget.isAssistant)
                          _actionButton(context, Iconsax.trash, appLocalizations.deleteClass, onTap: () async {
                              await showDialog(
                                context: context,
                                barrierDismissible: true,
                                builder: (context) => AlertDialog(
                                  title: Row(
                                    children: [
                                      Icon(Iconsax.warning_2, color: Colors.red),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          "${appLocalizations.deleteClassTitle} ${classItem.className}",
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                  content: Text(appLocalizations.deleteClassWarning),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(false),
                                      child: Text(appLocalizations.cancel),
                                    ),
                                    ElevatedButton(
                                      onPressed: () => Navigator.of(context).pop(true),
                                      child: Text(appLocalizations.delete),
                                    ),
                                  ],
                                ),
                              ).then((confirmed) async {
                                if (confirmed == true) {
                                  final success = await instructorClassService.deleteClass(widget.classId);

                                  if (success) {
                                    Get.back();
                                    Get.snackbar(
                                      appLocalizations.success,
                                      appLocalizations.classDeleted,
                                      snackPosition: SnackPosition.BOTTOM,
                                    );
                                  } else {
                                    Get.snackbar(
                                      appLocalizations.error,
                                      appLocalizations.errorMessage,
                                      snackPosition: SnackPosition.BOTTOM,
                                    );
                                  }
                                }
                            });
                          }),
                      ],
                    ),
                    const SizedBox(height: TSizes.spaceBtwSections),

                    /// STUDENT LIST
                    _buildSectionTitle(context, appLocalizations.students),
                    TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      decoration: InputDecoration(
                        hintText: appLocalizations.searchStudents,
                        prefixIcon: Icon(Iconsax.search_normal),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: filteredStudents.length,
                      itemBuilder: (context, index) {
                        final studentItem = filteredStudents[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: TSizes.iconXs),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(TSizes.md)),
                          elevation: 4,
                          child: ListTile(
                            leading: CircleAvatar(child: Text("S${index + 1}")),
                            title: Text(
                              "${studentItem.firstName ?? ''} ${studentItem.lastName ?? ''}",
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            subtitle: Text(
                              studentItem.email ?? '',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            trailing: studentItem.isActive
                                ? const Icon(Iconsax.arrow_21, size: TSizes.md)
                                : SizedBox(
                                    width: 100, // max width for both buttons
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(Iconsax.close_square, color: Color(0xFFDF1E42)),
                                            tooltip: appLocalizations.ignore,
                                            onPressed: () async {
                                              await classStudentService.ignoreStudent(
                                                  widget.classId,
                                                  studentItem.userId!
                                              );
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(Iconsax.tick_square, color: Colors.green),
                                            tooltip: appLocalizations.accept,
                                            onPressed: () async {
                                              await classStudentService.acceptStudent(
                                                  widget.classId,
                                                  studentItem.userId!
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                ),
                            onTap: studentItem.isActive
                                ? () async {

                                }
                                : null
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: TSizes.spaceBtwSections),

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
                          'https://api.qrserver.com/v1/create-qr-code/?data=${Uri.encodeComponent(classItem.qrCode!)}&size=200x200',
                          height: 250,
                          width: 250,
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
      icon: Icon(icon, size: TSizes.iconSm),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

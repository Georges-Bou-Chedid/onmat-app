import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:onmat/controllers/classItem/class_graduation.dart';
import 'package:onmat/models/Instructor.dart';
import 'package:onmat/screens/instructor/dashboard/student_profile.dart';
import 'package:provider/provider.dart';
import 'package:country_picker/country_picker.dart';

import '../../../controllers/instructor/class_assistant.dart';
import '../../../controllers/instructor/instructor.dart';
import '../../../controllers/instructor/instructor_class.dart';
import '../../../controllers/student/class_student.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/Belt.dart';
import '../../../models/Student.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/helpers/helper_functions.dart';
import '../../../utils/widgets/assign_assistant_dialog.dart';
import '../../../utils/widgets/background_image_header_container.dart';
import '../../../utils/widgets/belt_dialog.dart';
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

class _ClassDetailsScreenState extends State<ClassDetailsScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late Instructor? instructor;
  late FocusNode _searchFocusNode;
  String _searchQuery = '';
  int currentPage = 0;
  int studentsPerPage = 10;
  late TabController _tabController;
  late List<Student> myAttendanceStudents;
  Map<String, dynamic>? todaySchedule;
  final Color primaryBrandColor = const Color(0xFFDF1E42);
  bool extraSession = false;
  bool isEditing = false;
  bool hasChanges = false;
  bool isLoading = false;

  late ClassAssistantService _classAssistantService;
  late ClassStudentService _classStudentService;
  late ClassGraduationService _classGraduationService;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _searchFocusNode = FocusNode();
    myAttendanceStudents = [];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Safely get providers once here, where context is stable
    _classAssistantService = Provider.of<ClassAssistantService>(context, listen: false);
    _classStudentService = Provider.of<ClassStudentService>(context, listen: false);
    _classGraduationService = Provider.of<ClassGraduationService>(context, listen: false);
    final instructorClassService = Provider.of<InstructorClassService>(context, listen: false);
    final classItem = widget.isAssistant
        ? instructorClassService.assistantClasses.firstWhereOrNull((cl) => cl.id == widget.classId)
        : instructorClassService.ownerClasses.firstWhereOrNull((cl) => cl.id == widget.classId);
  }

  @override
  void dispose() {
    _classAssistantService.cancelListener();
    _classStudentService.cancelListener();
    _classGraduationService.cancelListener();

    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  bool hasOverlap(Belt newBelt, List<Belt> existingBelts) {
    for (final b in existingBelts) {
      final sameBeltColor =
          b.beltColor1.value == newBelt.beltColor1.value &&
              (b.beltColor2?.value ?? -1) == (newBelt.beltColor2?.value ?? -1);

      if (sameBeltColor) {
        if (!(newBelt.maxAge < b.minAge || newBelt.minAge > b.maxAge)) {
          return true;
        }
      }
    }
    return false;
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
    // In your build method
    final startIndex = currentPage * studentsPerPage;
    final endIndex = (startIndex + studentsPerPage).clamp(0, filteredStudents.length);
    final paginatedStudents = filteredStudents.sublist(startIndex, endIndex);

    /// Save Graduation Belts
    final classGraduationService = Provider.of<ClassGraduationService>(context, listen: true);

    final appLocalizations = AppLocalizations.of(context)!;
    final dark = THelperFunctions.isDarkMode(context);

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
                    /// 1. Consistent SafeArea Top Bar
                    SafeArea(
                      bottom: false,
                      child: SizedBox(
                        height: 65, // Matches the Dashboard height exactly
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            /// BACK BUTTON
                            IconButton(
                              padding: EdgeInsets.zero, // Removes extra button padding
                              constraints: const BoxConstraints(), // Allows button to sit tighter to the edge
                              icon: const Icon(Iconsax.arrow_left_2, size: 24),
                              onPressed: () => Get.back(),
                              color: Colors.white,
                            ),
                            const SizedBox(width: 8),

                            /// LOGO
                            Image.asset('assets/images/logo-white.png', height: 45),
                          ],
                        ),
                      ),
                    ),

                    /// 2. TITLE SECTION
                    Align(
                      alignment: Alignment.centerLeft,
                      child: ListTile(
                        title: Text(
                          classItem.className ?? '',
                          style: Theme.of(context).textTheme.headlineSmall!.apply(color: Colors.white),
                        ),
                        /// Adding an empty subtitle or a small spacer keeps the vertical rhythm
                        /// identical to the Dashboard's two-line ListTile
                        subtitle: const Text(''),
                      ),
                    ),
                    const SizedBox(height: TSizes.appBarHeight),
                  ],
                ),
              ),

              /// Tabs
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: TSizes.md),
                child: Column(
                  children: [
                    /// TabBar
                    Material(
                      elevation: 2,
                      color: dark ? Color(0xFF1E1E1E) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      child: TabBar(
                        controller: _tabController,
                        isScrollable: true,
                        tabAlignment: TabAlignment.center,
                        tabs: [
                          Tab(text: appLocalizations.details),
                          Tab(text: "${appLocalizations.students} (${myStudents.length})"),
                          Tab(text: "${appLocalizations.attendance} (${myAttendanceStudents.length})"),
                          Tab(text: appLocalizations.graduationSystem)
                        ],
                      ),
                    ),
                    const SizedBox(height: TSizes.spaceBtwSections),

                    /// TabBarView with filtered class lists
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildDetailsTab(appLocalizations, classItem, myAssistants, instructorClassService),
                          _buildStudentsTab(appLocalizations, paginatedStudents, classStudentService, startIndex, endIndex, filteredStudents),
                          _buildAttendanceTab(classItem, appLocalizations, classStudentService),
                          _buildGraduationTab(classItem, classGraduationService, appLocalizations),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsTab(appLocalizations, classItem, myAssistants, instructorClassService) {
    return SingleChildScrollView(
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
                  _infoRow(appLocalizations.headCoach, "${instructor!.firstName} ${instructor!.lastName}"),
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
    );
  }

  Widget _buildStudentsTab(appLocalizations, paginatedStudents, classStudentService, startIndex, endIndex, filteredStudents) {
    final dark = THelperFunctions.isDarkMode(context);

    return Column(
      children: [
        /// SEARCH BAR (Pill Style)
        TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          decoration: InputDecoration(
            hintText: appLocalizations.searchStudents,
            prefixIcon: const Icon(Iconsax.search_normal),
            filled: true,
            fillColor: dark ? Colors.grey[900] : Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
          ),
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
        ),
        const SizedBox(height: TSizes.spaceBtwItems),

        /// STUDENTS LIST
        ListView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: paginatedStudents.length,
          itemBuilder: (context, index) {
            final studentItem = paginatedStudents[index];

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: IntrinsicHeight(
                  child: Row(
                    children: [
                      // BRAND ACCENT LINE
                      Container(width: 5, color: primaryBrandColor),
                      Expanded(
                        child: InkWell(
                          onTap: studentItem.isActive
                              ? () => Get.to(
                                () => StudentProfileScreen(
                              studentId: studentItem.userId,
                              classId: widget.classId,
                              isAssistant: widget.isAssistant,
                              showInstructorFeatures: true,
                            ),
                            transition: Transition.rightToLeft,
                          )
                              : null,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                // AVATAR
                                CircleAvatar(
                                  radius: 22,
                                  backgroundColor: primaryBrandColor.withOpacity(0.1),
                                  child: Text(
                                    studentItem.firstName?[0].toUpperCase() ?? '?',
                                    style: TextStyle(color: primaryBrandColor, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(width: 12),

                                // INFO
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "${studentItem.firstName} ${studentItem.lastName}",
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                      ),
                                      Text(
                                        studentItem.email ?? '',
                                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),

                                // ACTIONS (TRAILING)
                                if (studentItem.isActive)
                                  const Icon(Iconsax.arrow_right_3, size: 16, color: Colors.grey)
                                else
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        constraints: const BoxConstraints(),
                                        padding: const EdgeInsets.symmetric(horizontal: 4),
                                        icon: const Icon(Iconsax.close_square, color: Color(0xFFDF1E42), size: 28),
                                        onPressed: () async => await classStudentService.ignoreStudent(widget.classId, studentItem.userId!),
                                      ),
                                      IconButton(
                                        constraints: const BoxConstraints(),
                                        padding: const EdgeInsets.symmetric(horizontal: 4),
                                        icon: const Icon(Iconsax.tick_square, color: Colors.green, size: 28),
                                        onPressed: () async => await classStudentService.acceptStudent(
                                            widget.classId,
                                            studentItem.userId!,
                                            '${studentItem.firstName} ${studentItem.lastName}'
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),

        /// PAGINATION CONTROLS
        Padding(
          padding: const EdgeInsets.symmetric(vertical: TSizes.md),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Iconsax.arrow_left),
                color: primaryBrandColor,
                onPressed: currentPage > 0 ? () => setState(() => currentPage--) : null,
              ),
              Text(
                "${startIndex + 1}–$endIndex of ${filteredStudents.length}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Iconsax.arrow_right),
                color: primaryBrandColor,
                onPressed: endIndex < filteredStudents.length ? () => setState(() => currentPage++) : null,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAttendanceTab(classItem, appLocalizations, classStudentService) {
    final today = DateTime.now();
    final dark = THelperFunctions.isDarkMode(context);
    final Color primaryBrandColor = const Color(0xFFDF1E42);

    const weekdayNames = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday',
    ];
    final todayName = weekdayNames[today.weekday - 1];

    if (!extraSession) {
      todaySchedule = classItem?.schedule?.firstWhere(
            (s) => s['day'] == todayName,
        orElse: () => <String, String>{},
      );

      if (todaySchedule!.isEmpty) {
        todaySchedule = null;
        myAttendanceStudents = [];
      } else {
        myAttendanceStudents = _classStudentService.myStudents
            .where((s) => !s.hasAttendanceToday && s.isActive == true)
            .toList();
      }
    }

    // --- NO CLASS SCHEDULED VIEW ---
    if (todaySchedule == null) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: dark ? Colors.grey[900] : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Iconsax.calendar_remove, size: 40, color: primaryBrandColor.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(
              appLocalizations.noClassScheduledToday,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: primaryBrandColor),
                icon: const Icon(Icons.add, color: Colors.white),
                label: Text(appLocalizations.addExtraSession, style: const TextStyle(color: Colors.white)),
                onPressed: () async {
                  final TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );

                  if (pickedTime != null) {
                    String? duration = await showDialog<String>(
                      context: context,
                      builder: (context) {
                        final controller = TextEditingController();
                        return AlertDialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          title: Text(appLocalizations.duration),
                          content: TextFormField(
                            controller: controller,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                                labelText: appLocalizations.duration,
                                prefixIcon: const Icon(Iconsax.timer)),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(appLocalizations.cancel, style: const TextStyle(color: Colors.grey)),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: primaryBrandColor),
                              onPressed: () {
                                if (controller.text.trim().isNotEmpty) {
                                  Navigator.pop(context, controller.text.trim());
                                }
                              },
                              child: Text(appLocalizations.save),
                            ),
                          ],
                        );
                      },
                    );

                    if (duration != null && duration.isNotEmpty) {
                      final newSchedule = {
                        'day': todayName,
                        'time': pickedTime.format(context),
                        'duration': duration,
                      };

                      setState(() {
                        extraSession = true;
                        myAttendanceStudents = _classStudentService.myStudents
                            .where((s) => !s.hasAttendanceToday && s.isActive == true)
                            .toList();
                        todaySchedule = newSchedule;
                      });
                    }
                  }
                },
              ),
            ),
          ],
        ),
      );
    }

    // --- ATTENDANCE LIST VIEW ---
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Schedule Header
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: dark ? Colors.white10 : Colors.black12)),
          ),
          child: Row(
            children: [
              Icon(Iconsax.clock, color: primaryBrandColor, size: 20),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(todayName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(
                    "${todaySchedule?['time']} • ${todaySchedule?['duration']} ${'min'}",
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        /// Student Cards
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: myAttendanceStudents.length,
            itemBuilder: (context, index) {
              final student = myAttendanceStudents[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: IntrinsicHeight(
                    child: Row(
                      children: [
                        // BRAND ACCENT LINE
                        Container(width: 5, color: primaryBrandColor),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 22,
                                  backgroundColor: primaryBrandColor.withOpacity(0.1),
                                  child: Text(
                                    student.firstName![0].toUpperCase(),
                                    style: TextStyle(color: primaryBrandColor, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "${student.firstName} ${student.lastName}",
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                      ),
                                      Text(
                                        student.email ?? '',
                                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Iconsax.tick_square, color: Colors.green, size: 28),
                                  onPressed: () async {
                                    setState(() {
                                      myAttendanceStudents.removeAt(index);
                                    });
                                    await classStudentService.updateAttendance(
                                      widget.classId,
                                      student.userId!,
                                      true,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGraduationTab(classItem, classGraduationService, AppLocalizations appLocalizations) {
    final myGraduationBelts = classGraduationService.myGradutationBelts;

    return Column(
      children: [
        myGraduationBelts.isEmpty
            ? Center(
              child: Text(
                appLocalizations.noBeltsFound,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            )
            : Expanded(
          child: ReorderableListView.builder(
            padding: EdgeInsets.zero,
            itemCount: myGraduationBelts.length,
            onReorder: isEditing
                ? (oldIndex, newIndex) {
                  setState(() {
                    classGraduationService.updateBeltOrder(oldIndex, newIndex);
                    hasChanges = true;
                  });
                }
                : (oldIndex, newIndex) {},
            itemBuilder: (context, index) {
              final belt = myGraduationBelts[index];
              return Card(
                key: ValueKey(belt.id),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                child: Padding(
                  padding: const EdgeInsets.all(TSizes.md),
                  child: Row(
                    children: [
                      // 1. DRAG HANDLE (Visible only in Edit Mode)
                      if (isEditing)
                        ReorderableDragStartListener(
                          index: index,
                          child: const Padding(
                            padding: EdgeInsets.only(right: 16),
                            child: Icon(Iconsax.row_vertical, color: Colors.grey),
                          ),
                        ),

                      // 2. BELT COLORS
                      _buildBeltBox(belt.beltColor1),
                      if (belt.beltColor2 != null) ...[
                        const SizedBox(width: 4),
                        _buildBeltBox(belt.beltColor2!),
                      ],

                      const SizedBox(width: 16),

                      // 3. BELT DETAILS
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${belt.minAge}–${belt.maxAge} ${appLocalizations.years}",
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            // Displaying priority helps you debug during development
                            Text(
                              "Rank ${belt.priority}: ${belt.maxStripes} Stripes • ${belt.classesPerBeltOrStripe} Classes",
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),

                      // 4. EDIT/DELETE ACTIONS
                      if (isEditing)
                      Column(
                        children: [
                          IconButton(
                            icon: const Icon(Iconsax.edit, color: Color(0xFFDF1E42)),
                            onPressed: () async {
                              final updatedBelt = await showDialog<Belt>(
                                context: context,
                                builder: (context) {
                                  return BeltDialog(
                                    beltToEdit: belt,
                                    existingBelts: myGraduationBelts,
                                    hasOverlap: hasOverlap,
                                  );
                                },
                              );

                              if (updatedBelt != null) {
                                setState(() {
                                  final index = myGraduationBelts.indexWhere((b) => b.id == updatedBelt.id);
                                  if (index != -1) {
                                    myGraduationBelts[index] = updatedBelt;
                                    hasChanges = true;
                                  }
                                });
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Iconsax.trash, color: Color(0xFFDF1E42)),
                            onPressed: () {
                              classGraduationService.removeBelt(index);
                              setState(() {
                                hasChanges = true;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        /// ACTIONS
        const SizedBox(height: 16),
        _buildSectionTitle(context, appLocalizations.actions),
        Wrap(
          spacing: TSizes.borderRadiusLg,
          runSpacing: TSizes.borderRadiusLg,
          children: [
            if (! isEditing && myGraduationBelts.isNotEmpty)
            _actionButton(context, Iconsax.edit, appLocalizations.edit, onTap: () {
              setState(() {
                isEditing = true;
              });
            }),
            if (isEditing || myGraduationBelts.isEmpty) ...[
              _actionButton(context, Iconsax.additem, appLocalizations.addBelt, onTap: () async {
                final newBelt = await showDialog<Belt>(
                  context: context,
                  builder: (context) {
                    return BeltDialog(
                      existingBelts: myGraduationBelts,
                      hasOverlap: hasOverlap, // Pass your overlap function
                    );
                  },
                );

                if (newBelt != null) {
                  classGraduationService.addBelt(newBelt);
                  setState(() {
                    isEditing = true;
                    hasChanges = true;
                  });
                }
              }),
              _actionButton(context, Iconsax.pen_close, appLocalizations.cancel, onTap: () {
                classGraduationService.cancelChanges();
                setState(() {
                  isEditing = false;
                  hasChanges = false;
                });
              }),
              if (hasChanges) ...[
                _actionButton(context, Iconsax.save_2, appLocalizations.saveChanges,
                    onTap: isLoading ? null : () async {
                  setState(() {
                    isLoading = true;
                  });
                  try {
                    final success = await classGraduationService.setBeltsForClass(widget.classId, myGraduationBelts);
                    if (success) {
                      Get.snackbar(
                        appLocalizations.success,
                        appLocalizations.classUpdatedMessage,
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    } else {
                      classGraduationService.cancelChanges();
                      Get.snackbar(
                        appLocalizations.error,
                        appLocalizations.errorMessage,
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    }
                  } finally {
                    setState(() {
                      isEditing = false;
                      isLoading = false;
                      hasChanges = false;
                    });
                  }
                }),
              ]
            ]
          ]),
        const SizedBox(height: TSizes.lg),
      ],
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

  Widget _actionButton(BuildContext context, IconData icon, String label, {required VoidCallback? onTap}) {
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

  Widget _buildBeltBox(Color color) {
    return Container(
      width: 24,
      height: 35,
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: Colors.black, width: 1.5),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

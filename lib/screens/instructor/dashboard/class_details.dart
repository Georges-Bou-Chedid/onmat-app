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
                    const SizedBox(height: TSizes.sm),
                    SizedBox(
                      height: 100, // enough height for your image
                      // padding: const EdgeInsets.all(TSizes.defaultSpace),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          IconButton(
                            icon: const Icon(Iconsax.arrow_left_2, size: 20), // Modern thin icon
                            onPressed: () => Get.back(),
                            color: Colors.white,
                          ),
                          Image.asset('assets/images/logo-white.png', height: 45)
                        ],
                      ),
                    ),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: ListTile(
                        title: Text(
                          classItem.className ?? '',
                          style: Theme.of(context).textTheme.headlineSmall!.apply(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: TSizes.appBarHeight)
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
    return Column(
        children: [
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
          Column(
            children: [
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: paginatedStudents.length,
                itemBuilder: (context, index) {
                  final studentItem = paginatedStudents[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: TSizes.iconXs),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(TSizes.md)),
                    elevation: 4,
                    child: ListTile(
                        leading: CircleAvatar(child: Text(studentItem.firstName[0])),
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
                          Get.to(() => StudentProfileScreen(
                              studentId: studentItem.userId,
                              classId: widget.classId,
                              isAssistant: widget.isAssistant,
                            ),
                            transition: Transition.rightToLeft,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                            : null
                    ),
                  );
                },
              ),

              // Pagination Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Iconsax.arrow_left_1, color: currentPage > 0 ? const Color(0xFFDF1E42) : Colors.grey),
                    onPressed: currentPage > 0
                        ? () {
                      setState(() {
                        currentPage--;
                      });
                    }
                        : null,
                  ),
                  Text(
                    "${startIndex + 1}-${endIndex} / ${filteredStudents.length}",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  IconButton(
                    icon: Icon(Iconsax.arrow_right_4, color: endIndex < filteredStudents.length ? const Color(0xFFDF1E42) : Colors.grey),
                    onPressed: endIndex < filteredStudents.length
                        ? () {
                      setState(() {
                        currentPage++;
                      });
                    }
                        : null,
                  ),
                ],
              ),
            ],
          ),
        ]
    );
  }

  Widget _buildAttendanceTab(classItem, appLocalizations, classStudentService) {
    final today = DateTime.now();
    const weekdayNames = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    final todayName = weekdayNames[today.weekday - 1];

    if (! extraSession) {
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

    if (todaySchedule == null) {
      return Card(
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(appLocalizations.noClassScheduledToday),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                icon: const Icon(Icons.add),
                label: Text(appLocalizations.addExtraSession),
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
                          title: Text(appLocalizations.duration),
                          content: TextFormField(
                            controller: controller,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: appLocalizations.duration,
                              prefixIcon: const Icon(Iconsax.timer)
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(appLocalizations.cancel),
                            ),
                            ElevatedButton(
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
            ],
          ),
        ),
      );
    }

    // Otherwise show today’s attendance list
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0, left: 16.0),
          child: ListTile(
            leading: Icon(Iconsax.clock, color: Theme.of(context).primaryColor),
            title: Text("${todayName}"),
            subtitle: Text("${todaySchedule?['time']} • ${todaySchedule?['duration']}"),
          )
        ),

        Expanded(
          child: ListView.builder(
            itemCount: myAttendanceStudents.length,
            itemBuilder: (context, index) {
              final student = myAttendanceStudents[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(child: Text(student.firstName![0])),
                  title: Text(
                    "${student.firstName} ${student.lastName}",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  subtitle: Text(
                    student.email ?? '',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      Iconsax.tick_square,
                      color: Colors.green,
                    ),
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
                  classGraduationService.updateBeltOrder(oldIndex, newIndex);
                  setState(() {
                    hasChanges = true;
                  });
                }
                : (oldIndex, newIndex) {},
            itemBuilder: (context, index) {
              final belt = myGraduationBelts[index];
              return Card(
                key: ValueKey(belt.id),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                child: Padding(
                  padding: const EdgeInsets.all(TSizes.md),
                  child: Row(
                    children: [
                      // Belt colors
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildBeltBox(belt.beltColor1),
                          if (belt.beltColor2 != null) ...[
                            const SizedBox(width: 4),
                            _buildBeltBox(belt.beltColor2!),
                          ],
                        ],
                      ),

                      const SizedBox(width: 16),

                      // Belt details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: [
                                Chip(
                                  label: Text(
                                    "${belt.minAge}–${belt.maxAge} ${appLocalizations.years}",
                                    style: const TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                ),
                                Chip(
                                  label: belt.beltColor2 == null
                                      ? Text(Belt.getColorName(belt.beltColor1))
                                      : Text(
                                    "${Belt.getColorName(belt.beltColor1)}/${Belt.getColorName(belt.beltColor2!)}",
                                    style: const TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                ),
                                Chip(
                                  label: Text("${belt.maxStripes} ${appLocalizations.maxStripes}",
                                    style: const TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                ),
                                Chip(
                                  label: Text(
                                    "${belt.classesPerBeltOrStripe} ${appLocalizations.classesPerBeltOrStripe}",
                                    style: const TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

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
                                  }
                                  hasChanges = true;
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
                _actionButton(context, Iconsax.pen_close, appLocalizations.cancel, onTap: () {
                  classGraduationService.cancelChanges();
                  setState(() {
                    isEditing = false;
                    hasChanges = false;
                  });
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

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:onmat/models/Instructor.dart';
import 'package:provider/provider.dart';
import 'package:country_picker/country_picker.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Ensure this is imported for currentUser

import '../../../controllers/classItem/class_graduation.dart';
import '../../../controllers/instructor/class_assistant.dart';
import '../../../controllers/instructor/instructor_class.dart';
import '../../../controllers/student/class_student.dart';
import '../../../controllers/student/student_class.dart';
import '../../../l10n/app_localizations.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/helpers/helper_functions.dart';
import '../../../utils/widgets/background_image_header_container.dart';
import '../../instructor/dashboard/student_profile.dart';

class StudentClassDetailsScreen extends StatefulWidget {
  final String classId;

  const StudentClassDetailsScreen({super.key, required this.classId});

  @override
  _StudentClassDetailsScreenState createState() => _StudentClassDetailsScreenState();
}

class _StudentClassDetailsScreenState extends State<StudentClassDetailsScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late Instructor? instructor;
  late FocusNode _searchFocusNode;
  late TabController _tabController;

  late ClassAssistantService _classAssistantService;
  late ClassGraduationService _classGraduationService;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _searchFocusNode = FocusNode();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _classAssistantService = Provider.of<ClassAssistantService>(context, listen: false);
    _classGraduationService = Provider.of<ClassGraduationService>(context, listen: false);

    Provider.of<ClassStudentService>(context, listen: false).listenToClassStudents(widget.classId);
  }

  @override
  void dispose() {
    _classAssistantService.cancelListener();
    _classGraduationService.cancelListener();
    Provider.of<ClassStudentService>(context, listen: false).cancelListener();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final studentClassService = Provider.of<StudentClassService>(context, listen: true);
    final classItem = studentClassService.classes.firstWhereOrNull((cl) => cl.id == widget.classId);

    final classAssistantService = Provider.of<ClassAssistantService>(context, listen: true);
    final myAssistants = classAssistantService.myAssistants;

    final instructorClassService = Provider.of<InstructorClassService>(context, listen: true);
    instructor = instructorClassService.classOwner;

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
                    Material(
                      elevation: 2,
                      color: dark ? const Color(0xFF1E1E1E) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      child: TabBar(
                        controller: _tabController,
                        isScrollable: true,
                        tabAlignment: TabAlignment.center,
                        tabs: [
                          Tab(text: appLocalizations.details),
                          Tab(text: appLocalizations.graduationSystem)
                        ],
                      ),
                    ),
                    const SizedBox(height: TSizes.spaceBtwSections),

                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.65,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildDetailsTab(appLocalizations, classItem, myAssistants, instructorClassService),
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
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

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
                    _infoRow(appLocalizations.headCoach, "${instructor?.firstName ?? ''} ${instructor?.lastName ?? ''}"),
                    _infoRow(appLocalizations.type, classItem.classType ?? ''),
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

            const SizedBox(height: TSizes.spaceBtwSections),

            /// NEW: VIEW MY PROGRESS BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDF1E42),
                  padding: const EdgeInsets.symmetric(vertical: TSizes.md),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Iconsax.user_tick, color: Colors.white),
                label: Text(
                  "View My Progress",
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  if (currentUserId != null) {
                    Provider.of<ClassStudentService>(context, listen: false).listenToClassStudents(widget.classId);

                    Get.to(() => StudentProfileScreen(
                      studentId: currentUserId,
                      classId: widget.classId,
                      isAssistant: false,
                      showInstructorFeatures: false, // Disables Upgrade/Remove buttons
                    ));
                  }
                },
              ),
            ),
            const SizedBox(height: TSizes.appBarHeight),
          ]
      ),
    );
  }

  Widget _buildGraduationTab(classItem, classGraduationService, AppLocalizations appLocalizations) {
    final myGraduationBelts = classGraduationService.myGradutationBelts;

    return Column(
      children: [
        myGraduationBelts.isEmpty
            ? Center(child: Text(appLocalizations.noBeltsFound))
            : Expanded(
          child: ListView.builder( // Replaced Reorderable with standard list for students
            padding: EdgeInsets.zero,
            itemCount: myGraduationBelts.length,
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
                      _buildBeltBox(belt.beltColor1),
                      if (belt.beltColor2 != null) ...[
                        const SizedBox(width: 4),
                        _buildBeltBox(belt.beltColor2!),
                      ],
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${belt.minAge}–${belt.maxAge} ${appLocalizations.years}",
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${belt.maxStripes} Stripes • ${belt.classesPerBeltOrStripe} Classes Required",
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

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
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w600),
        ),
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
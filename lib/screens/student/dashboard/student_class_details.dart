import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:onmat/models/Instructor.dart';
import 'package:provider/provider.dart';
import 'package:country_picker/country_picker.dart';

import '../../../controllers/classItem/class_graduation.dart';
import '../../../controllers/instructor/class_assistant.dart';
import '../../../controllers/instructor/instructor_class.dart';
import '../../../controllers/student/student_class.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/Belt.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/helpers/helper_functions.dart';
import '../../../utils/widgets/background_image_header_container.dart';
import '../student_start.dart';

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
    // Cache the service instance safely
    _classAssistantService = Provider.of<ClassAssistantService>(context, listen: false);
    _classGraduationService = Provider.of<ClassGraduationService>(context, listen: false);
  }

  @override
  void dispose() {
    _classAssistantService.cancelListener();
    _classGraduationService.cancelListener();

    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// Save class
    final studentClassService = Provider.of<StudentClassService>(context, listen: true);
    final classItem = studentClassService.classes.firstWhereOrNull((cl) => cl.id == widget.classId);

    /// Save Assistants
    final classAssistantService = Provider.of<ClassAssistantService>(context, listen: true);
    final myAssistants = classAssistantService.myAssistants;

    /// Save Owner
    final instructorClassService = Provider.of<InstructorClassService>(context, listen: true);
    instructor = instructorClassService.classOwner;

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
                            onTap: () => Get.offAll(() => const StudentStartScreen()),
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
        ]
      ),
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
            onReorder: (oldIndex, newIndex) {},
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
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
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

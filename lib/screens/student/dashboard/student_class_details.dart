import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:onmat/models/Instructor.dart';
import 'package:provider/provider.dart';
import 'package:country_picker/country_picker.dart';

import '../../../controllers/instructor/class_assistant.dart';
import '../../../controllers/instructor/instructor_class.dart';
import '../../../controllers/student/student_class.dart';
import '../../../l10n/app_localizations.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/widgets/background_image_header_container.dart';
import '../student_start.dart';

class StudentClassDetailsScreen extends StatefulWidget {
  final String classId;

  const StudentClassDetailsScreen({super.key, required this.classId});

  @override
  _StudentClassDetailsScreenState createState() => _StudentClassDetailsScreenState();
}

class _StudentClassDetailsScreenState extends State<StudentClassDetailsScreen> {
  final TextEditingController _searchController = TextEditingController();
  late Instructor? instructor;
  late FocusNode _searchFocusNode;

  late ClassAssistantService _classAssistantService;

  @override
  void initState() {
    super.initState();
    _searchFocusNode = FocusNode();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Cache the service instance safely
    _classAssistantService = Provider.of<ClassAssistantService>(context, listen: false);
  }

  @override
  void dispose() {
    _classAssistantService.cancelListener();

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

                    _buildSectionTitle(context, appLocalizations.progress),
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
}

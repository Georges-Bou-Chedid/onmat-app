import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:onmat/controllers/classItem/class_graduation.dart';
import 'package:onmat/screens/instructor/dashboard/add_class.dart';
import 'package:provider/provider.dart';

import '../../../controllers/instructor/class_assistant.dart';
import '../../../controllers/instructor/instructor_class.dart';
import '../../../controllers/student/class_student.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/Class.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/helpers/helper_functions.dart';
import '../../../utils/widgets/background_image_header_container.dart';
import 'class_details.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late AppLocalizations appLocalizations;
  late FocusNode _searchFocusNode;
  late TabController _tabController;
  bool _isLoading = false;
  String _searchQuery = '';

  late InstructorClassService _instructorClassService;

  @override
  void initState() {
    super.initState();
    _searchFocusNode = FocusNode();
    _tabController = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() => _isLoading = true);
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        _instructorClassService.listenToAssistantClasses(uid);
        _instructorClassService.listenToOwnerClasses(uid); // Keep this for owner classes
      }
      setState(() => _isLoading = false);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _instructorClassService = Provider.of<InstructorClassService>(context, listen: false);
  }

  @override
  void dispose() {
    _instructorClassService.cancelAssistantListener();
    _instructorClassService.cancelOwnerListener();

    _tabController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final instructorClassService = Provider.of<InstructorClassService>(context, listen: true);
    appLocalizations = AppLocalizations.of(context)!;
    final dark = THelperFunctions.isDarkMode(context);

    return GestureDetector(
      onTap: () => _searchFocusNode.unfocus(),
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              /// Header
              TBackgroundImageHeaderContainer(
                image: 'assets/images/dashboard_background.jpg',
                child: Column(
                  children: [
                    Container(
                      height: 150,
                      padding: const EdgeInsets.only(top: TSizes.defaultSpace, left: 20, right: 20),
                      alignment: Alignment.centerLeft,
                      child: Image.asset(
                        'assets/images/logo-white.png',
                        width: 80,
                        height: 80,
                        fit: BoxFit.contain,
                      ),
                    ),
                    ListTile(
                      title: Text(
                        appLocalizations.myClasses,
                        style: Theme.of(context).textTheme.headlineSmall!.apply(color: Colors.white),
                      ),
                      trailing: ElevatedButton.icon(
                        onPressed: () {
                          _searchFocusNode.unfocus();
                          Get.to(
                            () => const AddClassScreen(),
                            transition: Transition.downToUp,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        icon: const Icon(Iconsax.additem),
                        label: Text(
                          appLocalizations.addClass,
                          style: Theme.of(context).textTheme.bodyMedium!.apply(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      )
                    ),
                    const SizedBox(height: TSizes.appBarHeight),
                  ],
                ),
              ),

              /// Search + Tabs + Class Lists
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: TSizes.md),
                child: Column(
                  children: [
                    /// Search Bar
                    TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      decoration: InputDecoration(
                        hintText: appLocalizations.searchClasses,
                        prefixIcon: const Icon(Iconsax.search_normal),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                    const SizedBox(height: TSizes.spaceBtwItems),

                    /// TabBar
                    Material(
                      elevation: 2, // adjust for desired shadow depth
                      color: dark ? Color(0xFF1E1E1E) : Colors.white, // match your app background or scaffold
                      borderRadius: BorderRadius.circular(20),
                      child: TabBar(
                        controller: _tabController,
                        tabs: [
                          Tab(text: appLocalizations.headCoach),
                          Tab(text: appLocalizations.assistantCoach),
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
                          buildClassList(instructorClassService.ownerClasses, false),
                          buildClassList(instructorClassService.assistantClasses, true),
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

  /// List Builder with Search Filtering
  Widget buildClassList(List<Class> classes, bool isAssistant) {
    final filtered = classes.where((cl) {
      final query = _searchQuery.trim().toLowerCase();
      return cl.className?.toLowerCase().contains(query) == true ||
          cl.classType?.toLowerCase().contains(query) == true ||
          cl.location?.toLowerCase().contains(query) == true;
    }).toList();

    if (_isLoading) {
      return Center(
        child: SizedBox(
          height: TSizes.lg,
          width: TSizes.lg,
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (filtered.isEmpty) {
      return Center(
        child: Text(
          appLocalizations.noClassesFound,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    return ListView.builder(
      itemCount: filtered.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) {
        final classItem = filtered[index];
        return Card(
          margin: const EdgeInsets.only(bottom: TSizes.spaceBtwItems),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(TSizes.md)),
          elevation: 4,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
              child: Icon(Icons.sports_martial_arts, color: Theme.of(context).primaryColor),
            ),
            title: Text(
              classItem.className ?? '',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: TSizes.xs),
                Row(
                  children: [
                    Icon(Iconsax.tag, size: TSizes.md, color: Colors.grey),
                    const SizedBox(width: TSizes.xs),
                    Text(classItem.classType ?? ''),
                  ],
                ),
                const SizedBox(height: TSizes.xs),
                Row(
                  children: [
                    Icon(Iconsax.location, size: TSizes.md, color: Colors.grey),
                    const SizedBox(width: TSizes.xs),
                    Text('${classItem.location}, ${classItem.country}'),
                  ],
                ),
              ],
            ),
            trailing: const Icon(Iconsax.arrow_21, size: TSizes.md),
            onTap: () async {
              _searchFocusNode.unfocus();

              // Show loading
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => const Center(
                  child: SizedBox(
                    height: TSizes.lg,
                    width: TSizes.lg,
                    child: CircularProgressIndicator(),
                  ),
                ),
              );

              /// Fetch Owner
              if (isAssistant) {
                final instructorClassService = Provider.of<InstructorClassService>(context, listen: false);
                await instructorClassService.getClassOwner(classItem.ownerId);
              }

              /// Fetch Assistants
              final classAssistantService = Provider.of<ClassAssistantService>(context, listen: false);
              classAssistantService.listenToClassAssistants(classItem.id);

              /// Fetch Students
              final classStudentService = Provider.of<ClassStudentService>(context, listen: false);
              classStudentService.listenToClassStudents(classItem.id);

              /// Fetch Graduation Belts
              final classGraduationService = Provider.of<ClassGraduationService>(context, listen: false);
              classGraduationService.listenToClassBelts(classItem.id);

              Get.back();

              Get.to(
                () => ClassDetailsScreen(classId: classItem.id, isAssistant: isAssistant),
                transition: Transition.rightToLeft,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
          ),
        );
      },
    );
  }
}

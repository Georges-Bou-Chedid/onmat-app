import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

import 'package:onmat/controllers/classItem/class_graduation.dart';
import 'package:onmat/screens/instructor/dashboard/add_class.dart';
import '../../../controllers/instructor/class_assistant.dart';
import '../../../controllers/instructor/instructor_class.dart';
import '../../../controllers/notification_service.dart';
import '../../../controllers/student/class_student.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/Class.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/helpers/helper_functions.dart';
import '../../../utils/widgets/background_image_header_container.dart';
import '../../notification.dart';
import '../settings/settings.dart';
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
  int _activeTabIndex = 0; // Tracking for the custom tab switcher

  late InstructorClassService _instructorClassService;

  @override
  void initState() {
    super.initState();
    _searchFocusNode = FocusNode();
    _tabController = TabController(length: 2, vsync: this);

    // Update local state when tab changes to refresh custom button styles
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      setState(() {
        _activeTabIndex = _tabController.index;
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() => _isLoading = true);
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        _instructorClassService.listenToAssistantClasses(uid);
        _instructorClassService.listenToOwnerClasses(uid);
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
        // PROFESSIONAL ADD BUTTON: Floating Action Button is more ergonomic and modern
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => Get.to(
                () => const AddClassScreen(),
            transition: Transition.downToUp,
            duration: const Duration(milliseconds: 300),
          ),
          backgroundColor: Theme.of(context).primaryColor,
          icon: const Icon(Iconsax.add_circle, color: Colors.white),
          label: Text(
            appLocalizations.addClass,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              /// Cleaned Header
              TBackgroundImageHeaderContainer(
                image: 'assets/images/dashboard_background.jpg',
                child: Column(
                  children: [
                    SafeArea(
                      bottom: false,
                      child: Padding(
                        /// Only add horizontal padding here to keep the logo away from edges
                        padding: const EdgeInsets.symmetric(horizontal: TSizes.defaultSpace),
                        child: SizedBox(
                          height: 65, // Giving it a clear height without crushing it
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              /// LOGO
                              Image.asset('assets/images/logo-white.png', height: 45),

                              /// RIGHT ACTIONS
                              Row(
                                children: [
                                  Stack(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Iconsax.notification, color: Colors.white),
                                        onPressed: () => Get.to(() => const NotificationScreen()),
                                      ),
                                      // Show red dot if count > 0
                                      Consumer<NotificationService>(
                                        builder: (_, service, __) => service.unreadCount > 0
                                            ? Positioned(
                                          right: 8,
                                          top: 8,
                                          child: Container(
                                            padding: const EdgeInsets.all(2),
                                            decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)),
                                            constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                                            child: Text(
                                              '${service.unreadCount}',
                                              style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        )
                                            : const SizedBox.shrink(),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: () => Get.to(() => const SettingsScreen()),
                                    child: const CircleAvatar(
                                      radius: 18,
                                      backgroundColor: Colors.white24,
                                      child: Icon(Iconsax.user, color: Colors.white, size: 20),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: ListTile(
                        title: Text(
                          appLocalizations.classes,
                          style: Theme.of(context).textTheme.headlineSmall!.apply(color: Colors.white),
                        ),
                        subtitle: Text(
                          appLocalizations.findYourClasses,
                          style: Theme.of(context).textTheme.bodySmall!.apply(color: Colors.white70),
                        ),
                      ),
                    ),
                    const SizedBox(height: TSizes.appBarHeight),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: TSizes.md),
                child: Column(
                  children: [
                    /// Modern Search Bar
                    TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      decoration: InputDecoration(
                        hintText: appLocalizations.searchClasses,
                        prefixIcon: const Icon(Iconsax.search_normal),
                        filled: true,
                        fillColor: dark ? Colors.grey[900] : Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (value) => setState(() => _searchQuery = value),
                    ),
                    const SizedBox(height: TSizes.spaceBtwItems),

                    /// PROFESSIONAL TAB SWITCHER (Segmented Pill)
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: dark ? Colors.grey[900] : Colors.grey[200],
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        children: [
                          _buildTabButton(0, appLocalizations.headCoach),
                          _buildTabButton(1, appLocalizations.assistantCoach),
                        ],
                      ),
                    ),
                    const SizedBox(height: TSizes.spaceBtwItems),

                    /// CLASS LISTS
                    _isLoading
                        ? const Padding(
                      padding: EdgeInsets.only(top: 50),
                      child: CircularProgressIndicator(),
                    )
                        : _activeTabIndex == 0
                        ? buildClassList(instructorClassService.ownerClasses, false)
                        : buildClassList(instructorClassService.assistantClasses, true),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Helper for the modern Segmented Control Tab
  Widget _buildTabButton(int index, String label) {
    final isActive = _activeTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          _tabController.animateTo(index);
          setState(() => _activeTabIndex = index);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? Theme.of(context).primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isActive
                ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))]
                : [],
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.grey[600],
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  /// List Builder with Professional Card Design
  Widget buildClassList(List<Class> classes, bool isAssistant) {
    final filtered = classes.where((cl) {
      final query = _searchQuery.trim().toLowerCase();
      return cl.className?.toLowerCase().contains(query) == true ||
          cl.location?.toLowerCase().contains(query) == true;
    }).toList();

    if (filtered.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 100),
        child: Column(
          children: [
            const Icon(Iconsax.box, size: 50, color: Colors.grey),
            const SizedBox(height: 10),
            Text(appLocalizations.noClassesFound, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: filtered.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 100), // Space for FAB
      itemBuilder: (context, index) {
        final classItem = filtered[index];
        return Container(
          margin: const EdgeInsets.only(bottom: TSizes.spaceBtwItems),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              )
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  // Martial Arts "Belt" Accent Line
                  Container(
                    width: 6,
                    color: Theme.of(context).primaryColor,
                  ),
                  Expanded(
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                      title: Text(
                        classItem.className ?? '',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Iconsax.location, size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                '${classItem.location}, ${classItem.country}',
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Iconsax.category, size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                classItem.classType ?? '',
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: const Icon(Iconsax.arrow_right_3, size: 18, color: Colors.grey),
                      onTap: () => _handleClassSelection(classItem, isAssistant),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Unified loading logic
  Future<void> _handleClassSelection(Class classItem, bool isAssistant) async {
    _searchFocusNode.unfocus();

    // Show professional overlay loader
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      if (isAssistant) {
        await Provider.of<InstructorClassService>(context, listen: false).getClassOwner(classItem.ownerId);
      }
      Provider.of<ClassAssistantService>(context, listen: false).listenToClassAssistants(classItem.id);
      Provider.of<ClassStudentService>(context, listen: false).listenToClassStudents(classItem.id);
      Provider.of<ClassGraduationService>(context, listen: false).listenToClassBelts(classItem.id);

      Get.back(); // Close loader

      Get.to(
        () => ClassDetailsScreen(classId: classItem.id, isAssistant: isAssistant),
        transition: Transition.rightToLeft,
        duration: const Duration(milliseconds: 300),
      );
    } catch (e) {
      Get.back(); // Close loader
      // Handle error (e.g., show a snackbar)
    }
  }
}
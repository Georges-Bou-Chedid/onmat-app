import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

// Student Specific Imports
import 'package:onmat/controllers/student/class_student.dart';
import 'package:onmat/screens/student/dashboard/student_class_details.dart';
import 'package:onmat/screens/student/dashboard/student_scan_qr_code.dart';
import '../../../controllers/auth.dart';
import '../../../controllers/classItem/class_graduation.dart';
import '../../../controllers/instructor/class_assistant.dart';
import '../../../controllers/instructor/instructor_class.dart';
import '../../../controllers/notification_service.dart';
import '../../../controllers/student/student.dart';
import '../../../controllers/student/student_class.dart';

// Utils & Helpers
import '../../../l10n/app_localizations.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/helpers/helper_functions.dart';
import '../../../utils/widgets/background_image_header_container.dart';
import '../../notification.dart';
import '../settings/student_settings.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  _StudentDashboardScreenState createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  final TextEditingController _searchController = TextEditingController();
  late AppLocalizations appLocalizations;
  late FocusNode _searchFocusNode;
  bool _isLoading = false;
  String _searchQuery = '';

  // BRAND COLOR TO MATCH COACH DASHBOARD
  final Color primaryBrandColor = const Color(0xFFDF1E42);

  late StudentClassService _studentClassService;

  @override
  void initState() {
    super.initState();
    _searchFocusNode = FocusNode();

    Future.delayed(Duration.zero, () {
      AuthService().saveDeviceToken();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() => _isLoading = true);
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        _studentClassService.listenToStudentClasses(uid);
        Provider.of<NotificationService>(context, listen: false).listenToNotifications(uid);
      }
      setState(() => _isLoading = false);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _studentClassService = Provider.of<StudentClassService>(context, listen: false);
  }

  @override
  void dispose() {
    _studentClassService.cancelListener();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final studentService = Provider.of<StudentService>(context, listen: false);
    final classStudentService = Provider.of<ClassStudentService>(context, listen: false);
    final studentClassService = Provider.of<StudentClassService>(context, listen: true);
    appLocalizations = AppLocalizations.of(context)!;
    final dark = THelperFunctions.isDarkMode(context);

    // Filtering logic matching the Coach Dashboard style
    final filtered = studentClassService.classes.where((cl) {
      final query = _searchQuery.trim().toLowerCase();
      return (cl.className?.toLowerCase().contains(query) ?? false) ||
          (cl.location?.toLowerCase().contains(query) ?? false) ||
          (cl.classType?.toLowerCase().contains(query) ?? false);
    }).toList();

    return GestureDetector(
      onTap: () => _searchFocusNode.unfocus(),
      child: Scaffold(
        // MODERN SCAN BUTTON: Matching the "Add Class" button style
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _handleQrScan(classStudentService, studentService),
          backgroundColor: primaryBrandColor,
          elevation: 4,
          icon: const Icon(Iconsax.scan_barcode, color: Colors.white),
          label: Text(
            appLocalizations.scanQr,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              /// Cleaned Header (Synced with Coach design)
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
                                    onTap: () => Get.to(() => const StudentSettingsScreen()),
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
                    /// Modern Search Bar (Synced design)
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
                    const SizedBox(height: TSizes.spaceBtwSections),

                    /// DATA LIST
                    _isLoading
                        ? Center(child: CircularProgressIndicator(color: primaryBrandColor))
                        : filtered.isEmpty
                        ? _buildEmptyState()
                        : _buildClassList(filtered),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Empty State Helper
  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.only(top: 80),
      child: Column(
        children: [
          const Icon(Iconsax.box, size: 50, color: Colors.grey),
          const SizedBox(height: 10),
          Text(appLocalizations.noClassesFound, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  /// Professional Class List with "Belt" Accent
  Widget _buildClassList(List filtered) {
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
                  // BRAND COLOR "BELT" ACCENT
                  Container(width: 6, color: primaryBrandColor),
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
                      onTap: () => _handleNavigation(classItem),
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

  /// QR Scan Logic with Navigation
  Future<void> _handleQrScan(ClassStudentService classStudentService, StudentService studentService) async {
    _searchFocusNode.unfocus();
    final scannedData = await Get.to(
          () => const StudentScanQrScreen(),
      transition: Transition.downToUp,
      duration: const Duration(milliseconds: 300),
    );

    if (scannedData != null) {
      final success = await classStudentService.addStudentToClass(
          scannedData, FirebaseAuth.instance.currentUser!.uid, studentService.student!);

      if (success) {
        Get.snackbar(
          appLocalizations.success,
          appLocalizations.requestToJoinClass,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          appLocalizations.error,
          appLocalizations.errorMessage,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  /// Unified Loading & Navigation Logic
  Future<void> _handleNavigation(dynamic classItem) async {
    _searchFocusNode.unfocus();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final instructorClassService = Provider.of<InstructorClassService>(context, listen: false);
      await instructorClassService.getClassOwner(classItem.ownerId);

      final classAssistantService = Provider.of<ClassAssistantService>(context, listen: false);
      classAssistantService.listenToClassAssistants(classItem.id);

      final classGraduationService = Provider.of<ClassGraduationService>(context, listen: false);
      classGraduationService.listenToClassBelts(classItem.id);

      Get.back(); // Close loader

      Get.to(
            () => StudentClassDetailsScreen(classId: classItem.id),
        transition: Transition.rightToLeft,
        duration: const Duration(milliseconds: 300),
      );
    } catch (e) {
      Get.back(); // Close loader
    }
  }
}
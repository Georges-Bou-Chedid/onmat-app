import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:onmat/controllers/student/class_student.dart';
import 'package:onmat/screens/student/dashboard/student_class_details.dart';
import 'package:onmat/screens/student/dashboard/student_scan_qr_code.dart';
import 'package:provider/provider.dart';

import '../../../controllers/classItem/class_graduation.dart';
import '../../../controllers/instructor/class_assistant.dart';
import '../../../controllers/instructor/instructor_class.dart';
import '../../../controllers/student/student.dart';
import '../../../controllers/student/student_class.dart';
import '../../../l10n/app_localizations.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/widgets/background_image_header_container.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  _StudentDashboardScreenState createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late AppLocalizations appLocalizations;
  late FocusNode _searchFocusNode;
  bool _isLoading = false;
  String _searchQuery = '';

  late StudentClassService _studentClassService;

  @override
  void initState() {
    super.initState();
    _searchFocusNode = FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() => _isLoading = true);
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        _studentClassService.listenToStudentClasses(uid);
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
    final filtered = studentClassService.classes.where((cl) {
      final query = _searchQuery.trim().toLowerCase();
      return cl.className?.toLowerCase().contains(query) == true ||
          cl.classType?.toLowerCase().contains(query) == true ||
          cl.location?.toLowerCase().contains(query) == true;
    }).toList();
    appLocalizations = AppLocalizations.of(context)!;

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
                        onPressed: () async {
                          _searchFocusNode.unfocus();
                          final scannedData = await Get.to(
                                () => const StudentScanQrScreen(),
                            transition: Transition.downToUp,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );

                          if (scannedData != null) {
                            final success = await classStudentService.addStudentToClass(
                                scannedData,
                                FirebaseAuth.instance.currentUser!.uid,
                                studentService.student!
                            );

                            if (success) {
                              Get.snackbar(
                                appLocalizations.success,
                                appLocalizations.requestToJoinClass,
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
                        },
                        icon: const Icon(Iconsax.scan_barcode, color: Colors.white),
                        label: Text(
                          appLocalizations.scanQr,
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
                    const SizedBox(height: TSizes.spaceBtwSections),

                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: filtered.isEmpty
                        ? Center(
                          child: Text(
                            appLocalizations.noClassesFound,
                            style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ) : _isLoading
                        ? Center(
                            child: SizedBox(
                              height: TSizes.lg,
                              width: TSizes.lg,
                              child: CircularProgressIndicator(),
                            ),
                        )
                        : ListView.builder(
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
                                final instructorClassService = Provider.of<InstructorClassService>(context, listen: false);
                                await instructorClassService.getClassOwner(classItem.ownerId);

                                /// Fetch Assistants
                                final classAssistantService = Provider.of<ClassAssistantService>(context, listen: false);
                                classAssistantService.listenToClassAssistants(classItem.id);

                                /// Fetch Graduation Belts
                                final classGraduationService = Provider.of<ClassGraduationService>(context, listen: false);
                                classGraduationService.listenToClassBelts(classItem.id);
                      
                                Get.back();
                      
                                Get.to(
                                  () => StudentClassDetailsScreen(classId: classItem.id),
                                  transition: Transition.rightToLeft,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              },
                            ),
                          );
                        },
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

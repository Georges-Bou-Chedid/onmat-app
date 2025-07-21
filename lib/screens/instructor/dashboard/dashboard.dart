import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:onmat/screens/instructor/dashboard/add_class.dart';
import 'package:provider/provider.dart';

import '../../../controllers/i_class.dart';
import '../../../l10n/app_localizations.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/widgets/background_image_header_container.dart';
import 'class_details.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  late AppLocalizations appLocalizations;
  late FocusNode _searchFocusNode;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _searchFocusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() => _isLoading = true);

      final classService = Provider.of<InstructorClassService>(context, listen: false);
      await classService.refresh();

      setState(() => _isLoading = false);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final classService = Provider.of<InstructorClassService>(context, listen: true);
    final myClasses = classService.myClasses;
    final filteredClasses = myClasses.where((cl) {
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
                /// -- Header
                TBackgroundImageHeaderContainer(
                  image: 'assets/images/dashboard_background.jpg',
                  child: Column(
                    children: [
                      /// AppBar
                      Container(
                        height: 150, // enough height for your image
                        padding: EdgeInsets.only(top: TSizes.defaultSpace, left: 20, right: 20),
                        alignment: Alignment.centerLeft,
                        child: Image.asset(
                          'assets/images/logo-white.png',
                          width: 80,
                          height: 80,
                          fit: BoxFit.contain,
                        ),
                      ),
      
                      /// Classes Card
                      ListTile(
                        title: Text(
                            appLocalizations.myClasses,
                            style: Theme.of(context).textTheme.headlineSmall!.apply(color: Colors.white)
                        ),
                        trailing: IconButton(
                            onPressed: (){
                              _searchFocusNode.unfocus();
                              Get.to(
                                () => const AddClassScreen(),
                                transition: Transition.downToUp,        // comes from bottom, exits at top
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,               // optional: smoother easing
                              );
                            },
                            icon: const Icon(Iconsax.additem, color: Colors.white)
                        ),
                      ),
                      const SizedBox(height: TSizes.appBarHeight)
                    ],
                  ),
                ),
      
                /// Body
                Padding(
                  padding: const EdgeInsets.only(left: TSizes.md, right: TSizes.md),
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
      
                      /// List
                      _isLoading
                          ? SizedBox(
                              height: MediaQuery.of(context).size.height * 0.5,
                              child: Center(
                                child: SizedBox(
                                  height: TSizes.lg,
                                  width: TSizes.lg,
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                            )
                          : filteredClasses.isEmpty
                              ? SizedBox(
                                  height: MediaQuery.of(context).size.height * 0.3,
                                  child: Center(
                                    child: Text(
                                      appLocalizations.noClassesFound,
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: filteredClasses.length,
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  padding: EdgeInsets.zero,
                                  itemBuilder: (context, index) {
                                    final classItem = filteredClasses[index];
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
                                        trailing: Icon(Iconsax.arrow_21, size: TSizes.md),
                                        onTap: () {
                                          _searchFocusNode.unfocus();
                                          Get.to(
                                            () => const ClassDetailsScreen(),
                                            transition: Transition.rightToLeft,
                                            duration: const Duration(milliseconds: 300),
                                            curve: Curves.easeInOut,
                                          );
                                        },
                                      ),
                                    );
                                  },
                              ),
                    ],
                  ),
                )
              ],
            ),
          )
      ),
    );
  }
}

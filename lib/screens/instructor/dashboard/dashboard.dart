import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:onmat/screens/instructor/dashboard/add_class.dart';
import 'package:provider/provider.dart';

import '../../../controllers/class.dart';
import '../../../l10n/app_localizations.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/widgets/primary_header_container.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  late AppLocalizations appLocalizations;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() => _isLoading = true);

      final classService = Provider.of<ClassService>(context, listen: false);
      await classService.refresh();

      setState(() => _isLoading = false);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final classService = Provider.of<ClassService>(context, listen: true);
    final myClasses = classService.myClasses;
    final filteredClasses = myClasses.where((cl) {
      final query = _searchQuery.trim().toLowerCase();
      return cl.className?.toLowerCase().contains(query) == true ||
          cl.classType?.toLowerCase().contains(query) == true ||
          cl.location?.toLowerCase().contains(query) == true;
    }).toList();
    appLocalizations = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [
                /// -- Header
                TPrimaryHeaderContainer(
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
                      const SizedBox(height: TSizes.spaceBtwSections)
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
                              child: const Center(
                                child: SizedBox(
                                  height: TSizes.lg,
                                  width: TSizes.lg,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1E1E1E)),
                                  ),
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
                                      elevation: 3,
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

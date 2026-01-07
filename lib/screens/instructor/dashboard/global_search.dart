import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';
import '../../../controllers/instructor/global_search.dart';
import '../../../models/Belt.dart';
import '../../../l10n/app_localizations.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/helpers/helper_functions.dart';
import '../../../utils/widgets/background_image_header_container.dart';

class GlobalStudentSearchScreen extends StatefulWidget {
  const GlobalStudentSearchScreen({super.key});

  @override
  _GlobalStudentSearchScreenState createState() => _GlobalStudentSearchScreenState();
}

class _GlobalStudentSearchScreenState extends State<GlobalStudentSearchScreen> {
  String query = "";
  String? gender;
  String? classType;
  Color? belt1Color;
  Color? belt2Color;
  RangeValues ageRange = const RangeValues(5, 60);
  bool _showFilters = false;

  // BRAND COLOR
  final Color primaryBrandColor = const Color(0xFFDF1E42);

  final List<String> genderOptions = ['Male', 'Female'];
  final List<String> classTypeOptions = ['Kids', 'Adults', 'Teens'];

  final Map<String, Color> beltColors = {
    'White': Colors.white,
    'Yellow': Colors.yellow,
    'Orange': Colors.orange,
    'Green': Colors.green,
    'Blue': Colors.blue,
    'Purple': Colors.purple,
    'Brown': Colors.brown,
    'Red': Colors.red,
    'Black': Colors.black,
  };

  void _applyFilters(GlobalStudentSearchService searchService) {
    searchService.applyFilters(
      query: query.isEmpty ? null : query,
      gender: gender,
      classType: classType,
      belt1Color: belt1Color,
      belt2Color: belt2Color,
      ageRange: ageRange,
    );
  }

  void _resetFilters(GlobalStudentSearchService searchService) {
    setState(() {
      query = "";
      gender = null;
      classType = null;
      belt1Color = null;
      belt2Color = null;
      ageRange = const RangeValues(5, 60);
    });
    searchService.resetFilters();
  }

  @override
  Widget build(BuildContext context) {
    final searchService = Provider.of<GlobalStudentSearchService>(context);
    final appLocalizations = AppLocalizations.of(context)!;
    final dark = THelperFunctions.isDarkMode(context);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              /// SYNCED HEADER
              TBackgroundImageHeaderContainer(
                image: 'assets/images/dashboard_background.jpg',
                child: Column(
                  children: [
                    const SizedBox(height: TSizes.sm),
                    Container(
                      height: 100,
                      padding: const EdgeInsets.all(TSizes.defaultSpace),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Image.asset('assets/images/logo-white.png', height: 45),
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: ListTile(
                        title: Text(
                          appLocalizations.globalSearch,
                          style: Theme.of(context).textTheme.headlineSmall!.apply(color: Colors.white),
                        ),
                        subtitle: Text(
                          appLocalizations.findStudents,
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
                    /// PILL SEARCH BAR
                    TextField(
                      decoration: InputDecoration(
                        hintText: appLocalizations.searchByNameOrEmail,
                        prefixIcon: const Icon(Iconsax.search_normal),
                        filled: true,
                        fillColor: dark ? Colors.grey[900] : Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (val) {
                        query = val;
                        _applyFilters(searchService);
                      },
                    ),
                    const SizedBox(height: TSizes.spaceBtwItems),

                    /// FILTER TOGGLE (CLEANER)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          appLocalizations.filters,
                          style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
                        ),
                        TextButton.icon(
                          onPressed: () => setState(() => _showFilters = !_showFilters),
                          icon: Icon(_showFilters ? Iconsax.filter_remove : Iconsax.filter_edit, size: 18, color: primaryBrandColor),
                          label: Text(_showFilters ? appLocalizations.hide : appLocalizations.show, style: TextStyle(color: primaryBrandColor)),
                        ),
                      ],
                    ),

                    if (_showFilters) ...[
                      const SizedBox(height: 8),
                      _buildFiltersPanel(context, searchService, dark, appLocalizations),
                      const SizedBox(height: TSizes.spaceBtwItems),
                    ],

                    /// RESULTS SUMMARY
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${appLocalizations.found} ${searchService.total} ${appLocalizations.st}',
                            style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.grey),
                          ),
                          if (gender != null || classType != null || belt1Color != null || query.isNotEmpty)
                            GestureDetector(
                              onTap: () => _resetFilters(searchService),
                              child: Text(appLocalizations.clearAll, style: TextStyle(color: primaryBrandColor, fontWeight: FontWeight.bold, fontSize: 12)),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(thickness: 0.5),

              /// RESULTS LIST
              searchService.isLoading
                  ? Padding(
                padding: const EdgeInsets.only(top: 50),
                child: CircularProgressIndicator(color: primaryBrandColor),
              )
                  : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: TSizes.md, vertical: 10),
                itemCount: searchService.paginatedResults.length,
                itemBuilder: (context, index) {
                  final s = searchService.paginatedResults[index];
                  final age = searchService.calculateAge(s.dob);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: IntrinsicHeight(
                        child: Row(
                          children: [
                            // BRAND ACCENT "BELT" LINE
                            Container(width: 5, color: primaryBrandColor),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 22,
                                          backgroundColor: primaryBrandColor.withOpacity(0.1),
                                          child: Text(s.firstName?[0].toUpperCase() ?? '?', style: TextStyle(color: primaryBrandColor, fontWeight: FontWeight.bold)),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text("${s.firstName} ${s.lastName}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                              Text(s.email ?? '', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                            ],
                                          ),
                                        ),
                                        const Icon(Iconsax.arrow_right_3, size: 16, color: Colors.grey),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        _infoChip(icon: Iconsax.calendar, label: '$age yrs', context: context),
                                        const SizedBox(width: 8),
                                        _infoChip(icon: Iconsax.user, label: s.gender ?? 'N/A', context: context),
                                        const Spacer(),
                                        // BELT VISUALIZATION
                                        _buildBeltBadge(s.belt1, s.belt2),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),

              if (searchService.paginatedResults.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(TSizes.md),
                  child: _buildPaginationControls(searchService, context),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Helper to build the belt display on the card
  Widget _buildBeltBadge(Color b1, Color? b2) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Container(
            width: 14, height: 14,
            decoration: BoxDecoration(color: b1, border: Border.all(width: 0.5), borderRadius: BorderRadius.circular(2)),
          ),
          if (b2 != null) ...[
            const SizedBox(width: 4),
            Container(
              width: 14, height: 14,
              decoration: BoxDecoration(color: b2, border: Border.all(width: 0.5), borderRadius: BorderRadius.circular(2)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoChip({required IconData icon, required String label, required BuildContext context}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: primaryBrandColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: primaryBrandColor),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 11, color: primaryBrandColor, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildFiltersPanel(BuildContext context, GlobalStudentSearchService searchService, bool dark, AppLocalizations appLocalizations) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: dark ? Colors.grey[900] : Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: dark ? Colors.white10 : Colors.black12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildFilterDropdown(appLocalizations.gender, gender, genderOptions, (v) => setState(() => gender = v))),
              const SizedBox(width: 12),
              Expanded(child: _buildFilterDropdown(appLocalizations.cl, classType, classTypeOptions, (v) => setState(() => classType = v))),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildBeltPicker(appLocalizations.primaryBelt, belt1Color, (c) => setState(() => belt1Color = c), appLocalizations)),
              const SizedBox(width: 12),
              Expanded(child: _buildBeltPicker(appLocalizations.secondaryBelt, belt2Color, (c) => setState(() => belt2Color = c), appLocalizations)),
            ],
          ),
          const SizedBox(height: 16),
          Theme(
            data: Theme.of(context).copyWith(sliderTheme: SliderThemeData(activeTrackColor: primaryBrandColor, thumbColor: primaryBrandColor)),
            child: RangeSlider(
              values: ageRange,
              min: 5, max: 60,
              divisions: 55,
              labels: RangeLabels("${ageRange.start.round()}", "${ageRange.end.round()}"),
              onChanged: (val) => setState(() => ageRange = val),
            ),
          ),
          Center(
            child: Text("${appLocalizations.age}: ${ageRange.start.round()} - ${ageRange.end.round()}", style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _applyFilters(searchService),
              style: ElevatedButton.styleFrom(backgroundColor: primaryBrandColor),
              child: Text(appLocalizations.applyFilters, style: const TextStyle(color: Colors.white)),
            ),
          )
        ],
      ),
    );
  }

  // Refined Dropdowns
  Widget _buildFilterDropdown(String label, String? value, List<String> opts, Function(String) onSet) {
    return DropdownButtonFormField<String>(
      value: value,
      // Standardizes the text style of the selected value
      style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 14, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 13), // Makes the label slightly smaller and cleaner
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      items: opts.map((e) => DropdownMenuItem(
        value: e,
        child: Text(e, style: const TextStyle(fontSize: 14)), // Matching font size
      )).toList(),
      onChanged: (v) => onSet(v!),
    );
  }

  Widget _buildBeltPicker(String label, Color? value, Function(Color) onSet, AppLocalizations appLocalizations) {
    return InkWell(
      onTap: () => _showBeltColorPicker(context, onSet),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 13), // Match label size
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), // Match dropdown padding
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // Pushes the arrow to the end
          children: [
            Row(
              children: [
                if (value != null)
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: value,
                      border: Border.all(width: 0.5, color: Colors.black),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                if (value != null) const SizedBox(width: 8),
                Text(
                  value == null ? appLocalizations.select : Belt.getColorName(value),
                  // Sync this style exactly with the dropdown
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: value == null ? Colors.grey[600] : null,
                  ),
                ),
              ],
            ),
            const Icon(Icons.arrow_drop_down, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }

  // Pagination with primary brand color
  Widget _buildPaginationControls(GlobalStudentSearchService searchService, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(icon: const Icon(Iconsax.arrow_left), onPressed: searchService.canGoPrevious ? searchService.previousPage : null, color: primaryBrandColor),
        Text("${searchService.pageStart}–${searchService.pageEnd} of ${searchService.total}", style: const TextStyle(fontWeight: FontWeight.bold)),
        IconButton(icon: const Icon(Iconsax.arrow_right), onPressed: searchService.canGoNext ? searchService.nextPage : null, color: primaryBrandColor),
      ],
    );
  }

  Future<void> _showBeltColorPicker(BuildContext context, Function(Color) onChanged) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Belt Color'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: beltColors.entries.map((e) => ListTile(
              leading: Container(width: 20, height: 20, color: e.value),
              title: Text(e.key),
              onTap: () { onChanged(e.value); Navigator.pop(context); },
            )).toList(),
          ),
        ),
      ),
    );
  }
}
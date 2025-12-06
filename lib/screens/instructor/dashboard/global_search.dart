import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/instructor/global_search.dart';

class GlobalStudentSearchScreen extends StatefulWidget {
  const GlobalStudentSearchScreen({super.key});

  @override
  _GlobalStudentSearchScreenState createState() => _GlobalStudentSearchScreenState();
}

class _GlobalStudentSearchScreenState extends State<GlobalStudentSearchScreen> {
  String query = "";
  String? gender;
  String? classType;
  String? belt;
  RangeValues ageRange = const RangeValues(5, 60);

  @override
  Widget build(BuildContext context) {
    final searchService = Provider.of<GlobalStudentSearchService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Search Students"),
      ),
      body: Column(
        children: [

          /// Search bar
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: "Search by name or email",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (val) {
                query = val;
                searchService.applyFilters(
                  query: query,
                  gender: gender,
                  classType: classType,
                  belt: belt,
                  ageRange: ageRange,
                );
              },
            ),
          ),

          /// Filter chips + dropdowns
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [

                /// Gender Filter
                FilterChip(
                  label: Text(gender ?? "Gender"),
                  selected: gender != null,
                  onSelected: (_) async {
                    // gender = await _pickGender();
                    searchService.applyFilters(
                      query: query,
                      gender: gender,
                      classType: classType,
                      belt: belt,
                      ageRange: ageRange,
                    );
                  },
                ),
                SizedBox(width: 8),

                /// Class Type filter
                FilterChip(
                  label: Text(classType ?? "Class Type"),
                  selected: classType != null,
                  onSelected: (_) async {
                    // classType = await _pickClassType();
                    searchService.applyFilters(
                      query: query,
                      gender: gender,
                      classType: classType,
                      belt: belt,
                      ageRange: ageRange,
                    );
                  },
                ),
                SizedBox(width: 8),

                /// Belt filter
                FilterChip(
                  label: Text(belt ?? "Belt Rank"),
                  selected: belt != null,
                  onSelected: (_) async {
                    // belt = await _pickBelt();
                    searchService.applyFilters(
                      query: query,
                      gender: gender,
                      classType: classType,
                      belt: belt,
                      ageRange: ageRange,
                    );
                  },
                ),
              ],
            ),
          ),

          /// Age slider
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: RangeSlider(
              values: ageRange,
              min: 5,
              max: 60,
              labels: RangeLabels(
                "${ageRange.start.round()}",
                "${ageRange.end.round()}",
              ),
              onChanged: (newRange) {
                setState(() => ageRange = newRange);
                searchService.applyFilters(
                  query: query,
                  gender: gender,
                  classType: classType,
                  belt: belt,
                  ageRange: ageRange,
                );
              },
            ),
          ),

          Divider(),

          /// Student results
          // Expanded(
          //   child: searchService.isLoading
          //       ? Center(child: CircularProgressIndicator())
          //       : ListView.builder(
          //     itemCount: searchService.paginatedResults.length,
          //     itemBuilder: (context, index) {
          //       final s = searchService.paginatedResults[index];
          //       return ListTile(
          //         leading: CircleAvatar(
          //           backgroundImage: s.profilePicture != null
          //               ? NetworkImage(s.profilePicture!)
          //               : null,
          //           child: s.profilePicture == null ? Text(s.firstName[0]) : null,
          //         ),
          //         title: Text("${s.firstName} ${s.lastName}"),
          //         subtitle: Text("Age: ${s.age} • Belt: ${s.belt}"),
          //         trailing: Icon(Icons.chevron_right),
          //         onTap: () {
          //           // Navigate to student profile
          //         },
          //       );
          //     },
          //   ),
          // ),

          /// Pagination
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: searchService.previousPage,
                ),
                Text("${searchService.pageStart}–${searchService.pageEnd} of ${searchService.total}"),
                IconButton(
                  icon: Icon(Icons.arrow_forward),
                  onPressed: searchService.nextPage,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

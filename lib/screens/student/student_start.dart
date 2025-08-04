import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:onmat/screens/student/settings/student_settings.dart';

import '../../l10n/app_localizations.dart';
import 'dashboard/student_dashboard.dart';

class StudentStartScreen extends StatefulWidget {
  const StudentStartScreen({super.key});

  @override
  State<StudentStartScreen> createState() => _StudentStartScreenState();
}

class _StudentStartScreenState extends State<StudentStartScreen> {
  late AppLocalizations appLocalizations;
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    StudentDashboardScreen(),
    StudentSettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    appLocalizations = AppLocalizations.of(context)!;

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Iconsax.home),
            label: appLocalizations.dashboard,
          ),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.user_octagon),
            label: appLocalizations.myAccount,
          ),
        ],
      ),
    );
  }
}

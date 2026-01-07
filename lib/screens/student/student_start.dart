import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../l10n/app_localizations.dart';
import '../../../utils/helpers/helper_functions.dart';
import 'dashboard/student_dashboard.dart';

class StudentStartScreen extends StatefulWidget {
  const StudentStartScreen({super.key});

  @override
  State<StudentStartScreen> createState() => _StudentStartScreenState();
}

class _StudentStartScreenState extends State<StudentStartScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    StudentDashboardScreen(), // Index 0
  ];

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    final dark = THelperFunctions.isDarkMode(context);
    const Color primaryBrandColor = Color(0xFFDF1E42);

    return Scaffold(
      /// IndexedStack keeps the state of pages alive when switching tabs
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),

      /// Show BottomBar only if there is more than 1 page
      bottomNavigationBar: _pages.length <= 1
          ? null
          : BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),

        // Styling to match your Brand Theme
        selectedItemColor: primaryBrandColor,
        unselectedItemColor: dark ? Colors.white60 : Colors.grey,
        backgroundColor: dark ? const Color(0xFF1E1E1E) : Colors.white,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 12),

        items: [
          BottomNavigationBarItem(
            icon: const Icon(Iconsax.home),
            activeIcon: const Icon(Iconsax.home_15, color: primaryBrandColor),
            label: appLocalizations.dashboard,
          ),
        ],
      ),
    );
  }
}
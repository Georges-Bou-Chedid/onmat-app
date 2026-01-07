import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import '../../l10n/app_localizations.dart';
import '../../../utils/helpers/helper_functions.dart';
import 'dashboard/dashboard.dart';
import 'dashboard/global_search.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    DashboardScreen(),
    GlobalStudentSearchScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    final dark = THelperFunctions.isDarkMode(context);
    const Color primaryBrandColor = Color(0xFFDF1E42);

    return Scaffold(
      /// IndexedStack prevents the screens from re-loading/losing state when switching tabs
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),

        // --- Premium Styling ---
        type: BottomNavigationBarType.fixed, // Keeps labels visible for all items
        backgroundColor: dark ? const Color(0xFF1E1E1E) : Colors.white,
        selectedItemColor: primaryBrandColor,
        unselectedItemColor: dark ? Colors.white60 : Colors.grey[600],
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, fontFamily: 'Inter'),
        unselectedLabelStyle: const TextStyle(fontSize: 12, fontFamily: 'Inter'),
        elevation: 10,

        items: [
          /// Dashboard Tab
          BottomNavigationBarItem(
            icon: const Icon(Iconsax.home),
            activeIcon: const Icon(Iconsax.home_15, color: primaryBrandColor), // Bold version when active
            label: appLocalizations.dashboard,
          ),

          /// Search Tab
          BottomNavigationBarItem(
            icon: const Icon(Iconsax.search_status),
            activeIcon: const Icon(Iconsax.search_status5, color: primaryBrandColor), // Bold version when active
            label: appLocalizations.search,
          ),
        ],
      ),
    );
  }
}
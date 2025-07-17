import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:onmat/screens/instructor/settings/settings.dart';

import '../../l10n/app_localizations.dart';
import 'dashboard/dashboard.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  late AppLocalizations appLocalizations;
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    DashboardScreen(),
    SettingsScreen(),
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

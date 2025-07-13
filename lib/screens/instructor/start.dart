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

  static final List<Widget> _pages = <Widget>[
    DashboardScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    appLocalizations = AppLocalizations.of(context)!;

    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
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

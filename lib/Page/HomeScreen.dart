import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_bottom_nav.dart';
import 'DashboardPage.dart';
import 'FloorPage.dart';
import 'TenantPage.dart';
import 'SettingsPage.dart';
import 'NotificationPage.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex     = 0;
  int _notificationCount = 3; // ✅ Badge Count

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  List<Widget> get _pages => [
    const DashboardPage(),
    FloorPage(onBackToDashboard: () => _onItemTapped(0)),
    const TenantPage(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ✅ CustomAppBar ជាមួយ Notification Badge
      appBar: _selectedIndex == 0
          ? CustomAppBar(
        userName: "RIn Smos",
        notificationCount: _notificationCount, // ✅ Pass Count
      )
          : null,

      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),

      bottomNavigationBar: CustomBottomNav(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
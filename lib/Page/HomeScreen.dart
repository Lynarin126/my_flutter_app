import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../widgets/custom_app_bar.dart';
import '../widgets/custom_bottom_nav.dart';
import 'DashboardPage.dart';
import 'FloorPage.dart';
import 'TenantPage.dart';
import 'SettingsPage.dart';
import 'NotificationPage.dart';

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic>? userData; // ទទួល optional userData ពី Login

  const HomeScreen({super.key, this.userData});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  int _notificationCount = 9;

  String _userName = "អ្នកប្រើប្រាស់"; // Default value
  bool _isLoadingName = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // 🔹 Function សម្រាប់ទាញយកឈ្មោះ User ពី Firebase Firestore
  Future<void> _loadUserData() async {
    // ប្រសិនបើមានទិន្នន័យស្រាប់ពី LoginScreen
    if (widget.userData != null && widget.userData!['fullName'] != null) {
      setState(() {
        _userName = widget.userData!['fullName'];
        _isLoadingName = false;
      });
      return;
    }

    // ប្រសិនបើគ្មាន គឺទាញយកចេញពី Firestore ដោយប្រើ Current User UID
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();

        if (userDoc.exists && userDoc.data() != null) {
          Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
          setState(() {
            _userName = data['fullName'] ?? "អ្នកប្រើប្រាស់";
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching user data: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoadingName = false);
      }
    }
  }

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
      // ✅ CustomAppBar បង្ហាញឈ្មោះដែលទាញចេញពី Firebase
      appBar: _selectedIndex == 0
          ? CustomAppBar(
        userName: _isLoadingName ? "កំពុងផ្ទុក..." : _userName,
        notificationCount: _notificationCount,
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
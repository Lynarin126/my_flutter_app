import 'package:flutter/material.dart';

class CustomBottomNav extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: selectedIndex,
      selectedItemColor: Colors.green,
      unselectedItemColor: Colors.grey,
      onTap: onItemTapped,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'ទំព័រគ្រប់គ្រង'),
        BottomNavigationBarItem(icon: Icon(Icons.home_work), label: 'ជាន់'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'អ្នកជួល'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'កំណត់'),
      ],
    );
  }
}
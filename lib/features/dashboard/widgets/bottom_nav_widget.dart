import 'package:flutter/material.dart';
import '../../home/home_screen.dart';
import '../../dashboard/dashboard_screen.dart';
import '../../home/profile_screen.dart';

class BottomNavWidget extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;

  const BottomNavWidget({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
  });

  void _handleTabTap(BuildContext context, int index) {
    if (index == currentIndex) return;
    onTabSelected(index);
    
    // Optional: Add navigation logic if needed
    switch (index) {
      case 0:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DashboardScreen()));
        break;
      case 1:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
        break;
      case 2:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) => _handleTabTap(context, index),
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: Colors.blueAccent,
      unselectedItemColor: Colors.black54,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
      items: [
        _buildNavItem(
          icon: Icons.dashboard,
          label: 'Dashboard',
          index: 0,
          activeColor: Colors.blue,
        ),
        _buildNavItem(
          icon: Icons.add_business,
          label: 'Add Hotel',
          index: 1,
          activeColor: Colors.green,
        ),
        _buildNavItem(
          icon: Icons.person,
          label: 'Profile',
          index: 2,
          activeColor: Colors.orange,
        ),
      ],
    );
  }

  BottomNavigationBarItem _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required Color activeColor,
  }) {
    return BottomNavigationBarItem(
      icon: Icon(
        icon,
        color: currentIndex == index ? activeColor : Colors.black54,
      ),
      label: label,
    );
  }
}
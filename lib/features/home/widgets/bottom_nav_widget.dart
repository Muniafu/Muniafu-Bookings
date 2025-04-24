import 'package:flutter/material.dart';

class BottomNavWidget extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;
  final List<BottomNavigationBarItem> items;
  final Color? selectedItemColor;
  final Color? unselectedItemColor;
  final Color? backgroundColor;
  final BottomNavigationBarType? type;
  final double? elevation;
  final double? selectedFontSize;
  final double? unselectedFontSize;
  final bool? showSelectedLabels;
  final bool? showUnselectedLabels;

  const BottomNavWidget({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    this.items = const [
      BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: 'Home',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.search),
        label: 'Search',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.person),
        label: 'Profile',
      ),
    ],
    this.selectedItemColor = Colors.blueAccent,
    this.unselectedItemColor = Colors.black54,
    this.backgroundColor = Colors.white,
    this.type = BottomNavigationBarType.fixed,
    this.elevation = 8.0,
    this.selectedFontSize = 14.0,
    this.unselectedFontSize = 12.0,
    this.showSelectedLabels = true,
    this.showUnselectedLabels = true,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTabSelected,
      items: items,
      selectedItemColor: selectedItemColor,
      unselectedItemColor: unselectedItemColor,
      backgroundColor: backgroundColor,
      type: type,
      elevation: elevation,
      selectedFontSize: selectedFontSize ?? 14.0,
      unselectedFontSize: unselectedFontSize ?? 12.0,
      showSelectedLabels: showSelectedLabels,
      showUnselectedLabels: showUnselectedLabels,
    );
  }
}
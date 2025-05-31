import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:muniafu/providers/navigation_provider.dart';

class BottomNavWidget extends StatelessWidget {
  final bool isAdmin;
  final int? currentIndex;
  final ValueChanged<int>? onTabSelected;
  final List<BottomNavigationBarItem>? items;
  final Color? selectedItemColor;
  final Color? unselectedItemColor;
  final Color? backgroundColor;
  final BottomNavigationBarType? type;
  final double? elevation;
  final double? selectedFontSize;
  final double? unselectedFontSize;
  final bool? showSelectedLabels;
  final bool? showUnselectedLabels;
  final IconThemeData? selectedIconTheme;
  final IconThemeData? unselectedIconTheme;

  const BottomNavWidget({
    super.key,
    this.isAdmin = false,
    this.currentIndex,
    this.onTabSelected,
    this.items,
    this.selectedItemColor = Colors.blueAccent,
    this.unselectedItemColor = Colors.black54,
    this.backgroundColor = Colors.white,
    this.type = BottomNavigationBarType.fixed,
    this.elevation = 8.0,
    this.selectedFontSize = 14.0,
    this.unselectedFontSize = 12.0,
    this.showSelectedLabels = true,
    this.showUnselectedLabels = true,
    this.selectedIconTheme,
    this.unselectedIconTheme,
  });

  @override
  Widget build(BuildContext context) {
    // Use provider if explicit values aren't provided
    final navProvider = currentIndex == null || onTabSelected == null
        ? Provider.of<NavigationProvider>(context)
        : null;
    
    final currentIdx = currentIndex ?? navProvider?.currentIndex ?? 0;
    final onTap = onTabSelected ?? (navProvider != null ? navProvider.updateIndex : null);

    // Build default items if not provided
    final navItems = items ?? _buildDefaultItems(context);

    return BottomNavigationBar(
      currentIndex: currentIdx,
      onTap: onTap,
      items: navItems,
      selectedItemColor: selectedItemColor,
      unselectedItemColor: unselectedItemColor,
      backgroundColor: backgroundColor,
      type: type,
      elevation: elevation,
      selectedFontSize: selectedFontSize ?? 14.0,
      unselectedFontSize: unselectedFontSize ?? 12.0,
      showSelectedLabels: showSelectedLabels,
      showUnselectedLabels: showUnselectedLabels,
      selectedIconTheme: selectedIconTheme,
      unselectedIconTheme: unselectedIconTheme,
      landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
    );
  }

  List<BottomNavigationBarItem> _buildDefaultItems(BuildContext context) {
    return [
      const BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined),
        activeIcon: Icon(Icons.home),
        label: 'Home',
      ),
      if (!isAdmin)
        const BottomNavigationBarItem(
          icon: Icon(Icons.book_outlined),
          activeIcon: Icon(Icons.book),
          label: 'Bookings',
        ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.person_outlined),
        activeIcon: Icon(Icons.person),
        label: 'Profile',
      ),
      if (isAdmin)
        const BottomNavigationBarItem(
          icon: Icon(Icons.admin_panel_settings_outlined),
          activeIcon: Icon(Icons.admin_panel_settings),
          label: 'Admin',
        ),
    ];
  }
}
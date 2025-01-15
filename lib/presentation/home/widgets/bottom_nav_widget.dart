import 'package:flutter/material.dart';

class HomeBottomNavWidget extends StatefulWidget{
  final Function(int) onTabSelected;
  final int currentIndex;

  const HomeBottomNavWidget({
    super.key,
    required this.onTabSelected,
    required this.currentIndex,
  });

  @override
  _HomeBottomNavWidgetState createState() => _HomeBottomNavWidgetState();
}

class _HomeBottomNavWidgetState extends State<HomeBottomNavWidget> {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: widget.currentIndex,
      onTap: widget.onTabSelected,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.hotel),
          label: 'Bookings',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
      selectedItemColor: Colors.blueAccent,
      unselectedItemColor: Colors.black,
      backgroundColor: Colors.red,
      type: BottomNavigationBarType.fixed,
      elevation: 8.0,
      selectedFontSize: 14.0,
      unselectedFontSize: 12.0,
      showSelectedLabels: true,
      showUnselectedLabels: true,
    );
  }
}
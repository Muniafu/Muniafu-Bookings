import 'package:flutter/material.dart';

class BottomNavWidget extends StatefulWidget {
  final Function(int) onTabSelected;
  final int currentIndex;

  const BottomNavWidget({
    super.key,
    required this.onTabSelected,
    required this.currentIndex,
  });

  @override
  _BottomNavWidgetState createState() => _BottomNavWidgetState();
}

class _BottomNavWidgetState extends State<BottomNavWidget> {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: widget.currentIndex,
      onTap: widget.onTabSelected,
      items: [
        BottomNavigationBarItem(
          icon: Icon(
            Icons.home,
            color: widget.currentIndex == 0 ? Colors.blue : Colors.black,
          ),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.add_business,
            color: widget.currentIndex == 1 ? Colors.green : Colors.black,
          ),
          label: 'Add Hotel',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.person,
            color: widget.currentIndex == 2 ? Colors.orange : Colors.black,
          ),
          label: 'Profile',
        ),
      ],
      selectedItemColor: Colors.blueAccent,
      unselectedItemColor: Colors.black,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
      unselectedLabelStyle: const TextStyle(color: Colors.black),
      backgroundColor: Colors.white,
      type: BottomNavigationBarType.fixed,
    );
  }
}

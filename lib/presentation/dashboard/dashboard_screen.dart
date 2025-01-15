import 'package:flutter/material.dart';
import 'package:muniafu/presentation/home/booking_screen.dart';
import 'package:muniafu/presentation/home/home_screen.dart';
import 'package:muniafu/presentation/home/profile_screen.dart';
import 'package:muniafu/presentation/search/search_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(),
    const BookingScreen(),
    const SearchScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.shifting, // Enable color animation
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Colors.blueAccent, // Color for selected item
        unselectedItemColor: Colors.grey, // Color for unselected items
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              color: _currentIndex == 0 ? Colors.blueAccent : Colors.grey,
            ),
            label: 'Home',
            backgroundColor: Colors.white, // Background color for item
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.book,
              color: _currentIndex == 1 ? Colors.green : Colors.grey,
            ),
            label: 'Bookings',
            backgroundColor: Colors.white,
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.search,
              color: _currentIndex == 2 ? Colors.orange : Colors.grey,
            ),
            label: 'Search',
            backgroundColor: Colors.white,
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person,
              color: _currentIndex == 3 ? Colors.purple : Colors.grey,
            ),
            label: 'Profile',
            backgroundColor: Colors.white,
          ),
        ],
      ),
    );
  }
}

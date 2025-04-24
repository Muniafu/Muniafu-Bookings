import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:muniafu/features/home/home_screen.dart';
import 'package:muniafu/features/home/profile_screen.dart';
import 'package:muniafu/features/search/search_screen.dart';
import 'widgets/add_hotels_widget.dart';

// Main navigation handler with bottom bar
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(),
    const BookingScreen(),  // Our renamed bookings screen
    const SearchScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.shifting,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
            backgroundColor: Colors.white,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Bookings',
            backgroundColor: Colors.white,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
            backgroundColor: Colors.white,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
            backgroundColor: Colors.white,
          ),
        ],
      ),
    );
  }
}

// Renamed from original DashboardScreen to BookingScreen
class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Your Bookings")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text("Current Bookings", 
                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const ListTile(
              leading: Icon(Icons.hotel),
              title: Text("Hotel Paradise - Deluxe Room"),
              subtitle: Text("Check-in: May 21, 2025"),
            ),
            const Divider(),
            const Text("Explore More", 
                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            AddHotelsWidget(
              onAddHotel: (Map<String, dynamic> hotelData) {
                // Handle the addition of a new hotel here
                // For example, you can send the data to your backend or update the state
                if (kDebugMode) {
                  print("New hotel added: $hotelData");
                }
                // Optionally, you can show a success message or navigate to another screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Hotel added successfully!")),
                );
              },
            ),  // Reusable hotel addition component
          ],
        ),
      ),
    );
  }
}
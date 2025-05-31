import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:muniafu/providers/navigation_provider.dart';
import 'package:muniafu/providers/auth_provider.dart';
import 'package:muniafu/app/core/widgets/bottom_nav_widget.dart';
import 'package:muniafu/features/home/home_screen.dart';
import 'package:muniafu/features/home/profile_screen.dart';
import 'package:muniafu/features/search/search_screen.dart';
import 'package:muniafu/features/authentication/screens/admin_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late List<Widget> _screens;
  late bool _isAdmin;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeScreens();
  }

  void _initializeScreens() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _isAdmin = authProvider.isAdmin;
    
    _screens = [
      const HomeScreen(),
      if (!_isAdmin) const BookingScreen(),
      if (!_isAdmin) const SearchScreen(),
      const ProfileScreen(),
      if (_isAdmin) const AdminScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NavigationProvider(),
      child: Consumer<NavigationProvider>(
        builder: (context, navProvider, _) {
          return Scaffold(
            body: IndexedStack(
              index: navProvider.currentIndex,
              children: _screens,
            ),
            bottomNavigationBar: BottomNavWidget(
              isAdmin: _isAdmin,
              currentIndex: navProvider.currentIndex,
              onTabSelected: navProvider.updateIndex,
            ),
          );
        },
      ),
    );
  }
}

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Bookings"),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              final navProvider = Provider.of<NavigationProvider>(context, listen: false);
              navProvider.updateIndex(2); // Navigate to search screen
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text(
              "Current Bookings", 
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildBookingItem(
              icon: Icons.hotel,
              title: "Hotel Paradise - Deluxe Room",
              subtitle: "Check-in: May 21, 2025",
              status: "Confirmed",
              statusColor: Colors.green,
            ),
            _buildBookingItem(
              icon: Icons.villa,
              title: "Mountain Resort - Premium Villa",
              subtitle: "Check-in: Jun 15, 2025",
              status: "Pending",
              statusColor: Colors.orange,
            ),
            const Divider(thickness: 1.5),
            const SizedBox(height: 20),
            const Text(
              "Explore More", 
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text("Add New Booking"),
              onPressed: () => _showBookingDialog(context),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String status,
    required Color statusColor,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(subtitle),
            const SizedBox(height: 4),
            Chip(
              label: Text(status),
              backgroundColor: statusColor.withOpacity(0.2),
              labelStyle: TextStyle(color: statusColor),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _showBookingDetails(context, title),
      ),
    );
  }

  void _showBookingDetails(BuildContext context, String title) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              const ListTile(
                leading: Icon(Icons.calendar_today),
                title: Text("Check-in Date"),
                subtitle: Text("May 21, 2025"),
              ),
              const ListTile(
                leading: Icon(Icons.calendar_today),
                title: Text("Check-out Date"),
                subtitle: Text("May 28, 2025"),
              ),
              const ListTile(
                leading: Icon(Icons.people),
                title: Text("Guests"),
                subtitle: Text("2 Adults, 1 Child"),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel Booking"),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      child: const Text("Modify"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showBookingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("New Booking"),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: 'Destination',
                  prefixIcon: Icon(Icons.location_on),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Check-in Date',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Check-out Date',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CANCEL"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Booking created successfully!")),
              );
            },
            child: const Text("BOOK NOW"),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:muniafu/providers/admin_provider.dart';
import 'package:muniafu/app/core/widgets/background_widget.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final List<AdminDashboardItem> _dashboardItems = [
    AdminDashboardItem(
      title: 'Manage Hotels',
      icon: Icons.hotel,
      color: Colors.blue,
      screen: const HotelManagementScreen(),
    ),
    AdminDashboardItem(
      title: 'Bookings',
      icon: Icons.calendar_today,
      color: Colors.green,
      screen: const BookingManagementScreen(),
    ),
    AdminDashboardItem(
      title: 'Users',
      icon: Icons.people,
      color: Colors.orange,
      screen: const PlaceholderScreen(title: 'User Management'),
    ),
    AdminDashboardItem(
      title: 'Settings',
      icon: Icons.settings,
      color: Colors.purple,
      screen: const PlaceholderScreen(title: 'Admin Settings'),
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        centerTitle: true,
        elevation: 0,
      ),
      body: BackgroundWidget(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 24),
              _buildDashboardGrid(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Admin Panel',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Manage hotels, bookings, and users',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildDashboardGrid() {
    return Expanded(
      child: GridView.count(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: _dashboardItems.map((item) => _buildAdminCard(item)).toList(),
      ),
    );
  }

  Widget _buildAdminCard(AdminDashboardItem item) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _navigateToScreen(item.screen),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(item.icon, size: 40, color: item.color),
              const SizedBox(height: 12),
              Text(
                item.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToScreen(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }
}

class HotelManagementScreen extends StatelessWidget {
  const HotelManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Hotels")),
      body: Consumer<AdminProvider>(
        builder: (context, provider, _) {
          if (provider.hotels.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          return HotelList(hotels: provider.hotels);
        },
      ),
    );
  }
}

class BookingManagementScreen extends StatelessWidget {
  const BookingManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Bookings")),
      body: Consumer<AdminProvider>(
        builder: (context, provider, _) {
          if (provider.bookings.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          return BookingList(bookings: provider.bookings);
        },
      ),
    );
  }
}

class HotelList extends StatelessWidget {
  final List<Map<String, dynamic>> hotels;
  
  const HotelList({required this.hotels, super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AdminProvider>(context, listen: false);
    
    return ListView.builder(
      itemCount: hotels.length,
      itemBuilder: (_, index) {
        final hotel = hotels[index];
        return Card(
          child: ListTile(
            title: Text(hotel['name'] ?? 'Unnamed Hotel'),
            subtitle: Text(hotel['location'] ?? 'Location not specified'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.check, color: Colors.green),
                  onPressed: () => provider.approveRoom(hotel['id']),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () => provider.rejectRoom(hotel['id']),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class BookingList extends StatelessWidget {
  final List<Map<String, dynamic>> bookings;
  
  const BookingList({required this.bookings, super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: bookings.length,
      itemBuilder: (_, index) {
        final booking = bookings[index];
        return ListTile(
          title: Text("Booking: ${booking['id'] ?? 'N/A'}"),
          subtitle: Text(
            "User: ${booking['user'] ?? 'Unknown'} | Room: ${booking['room'] ?? 'Unspecified'}"
          ),
        );
      },
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  final String title;
  
  const PlaceholderScreen({required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: const Center(child: Text('Feature coming soon!')),
    );
  }
}

class AdminDashboardItem {
  final String title;
  final IconData icon;
  final Color color;
  final Widget screen;

  AdminDashboardItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.screen,
  });
}
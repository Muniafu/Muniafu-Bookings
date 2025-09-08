import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final isAdmin = auth.user?.role == 'admin';

    if (!isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text("Access Denied")),
        body: const Center(child: Text("You are not authorized to view this screen.")),
      );
    }

    final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);

    final List<_DashboardItem> adminSections = [
      _DashboardItem(
        title: 'Send Notification',
        icon: Icons.notifications_active,
        color: Colors.redAccent,
        routeName: '/admin/send-notification',
        badgeStream: notificationProvider.listenToUnreadNotificationCount(),
      ),
      _DashboardItem(
        title: 'Manage Properties',
        icon: Icons.home_work,
        color: Colors.blueAccent,
        routeName: '/admin/properties',
      ),
      _DashboardItem(
        title: 'Manage Bookings',
        icon: Icons.book_online,
        color: Colors.orange,
        routeName: '/admin/bookings',
      ),
      _DashboardItem(
        title: 'Add New Property',
        icon: Icons.add_business,
        color: Colors.green,
        routeName: '/admin/add-property',
      ),
      _DashboardItem(
        title: 'Analytics & Reports',
        icon: Icons.analytics,
        color: Colors.deepPurple,
        routeName: '/admin/analytics',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              auth.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Admin Functions",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.builder(
                itemCount: adminSections.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // responsive on wide screens
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1,
                ),
                itemBuilder: (context, index) {
                  final item = adminSections[index];
                  return _DashboardCard(item: item);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardItem {
  final String title;
  final IconData icon;
  final Color color;
  final String routeName;
  final Stream<int>? badgeStream;

  _DashboardItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.routeName,
    this.badgeStream,
  });
}

class _DashboardCard extends StatelessWidget {
  final _DashboardItem item;

  const _DashboardCard({required this.item});

  @override
  Widget build(BuildContext context) {
    if (item.badgeStream != null) {
      return StreamBuilder<int>(
        stream: item.badgeStream,
        builder: (context, snapshot) {
          final count = snapshot.data ?? 0;
          return _buildCard(context, badgeCount: count);
        },
      );
    }
    return _buildCard(context);
  }

  Widget _buildCard(BuildContext context, {int badgeCount = 0}) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, item.routeName);
      },
      child: Card(
        elevation: 4,
        color: item.color.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundColor: item.color,
                    radius: 28,
                    child: Icon(item.icon, color: Colors.white, size: 28),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    item.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: item.color.withRed(600),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (badgeCount > 0)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$badgeCount',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
      ),    
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/user.dart';
import 'package:muniafu/providers/user_provider.dart';
import 'package:muniafu/app/core/widgets/button_widget.dart';
import 'payment_screen.dart';
import 'package:muniafu/features/authentication/screens/welcome_screen.dart';
import 'package:muniafu/features/home/widgets/profile_info_row.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _navigateToEditProfile(context),
            tooltip: 'Edit Profile',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Settings'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Overview Tab
          _buildOverviewTab(context, user),
          // Settings Tab
          _buildSettingsTab(userProvider),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(BuildContext context, User? user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Profile Header Section
          _buildProfileHeader(context, user),
          const SizedBox(height: 24),
          
          // Quick Actions Section
          _buildQuickActions(context),
          const SizedBox(height: 24),
          
          // Personal Information Section
          _buildPersonalInfoSection(user),
          const SizedBox(height: 24),
          
          // Recent Activity Section
          _buildRecentActivity(),
          const SizedBox(height: 24),
          
          // Account Management Section
          _buildAccountManagement(context),
          const SizedBox(height: 24),
          
          // Logout Button
          _buildLogoutButton(context),
        ],
      ),
    );
  }

  Widget _buildSettingsTab(UserProvider userProvider) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SwitchListTile(
          title: const Text('Dark Mode'),
          value: userProvider.user?.darkMode ?? false,
          onChanged: (_) => userProvider.toggleDarkMode(),
        ),
        ListTile(
          leading: const Icon(Icons.verified_user),
          title: const Text('Verify Email'),
          onTap: userProvider.verifyEmail,
        ),
        ListTile(
          leading: const Icon(Icons.lock),
          title: const Text('Change Password'),
          onTap: () => _showChangePasswordDialog(context),
        ),
        ListTile(
          leading: const Icon(Icons.payment),
          title: const Text('Payment Methods'),
          onTap: () => _navigateToPaymentMethods(context),
        ),
        ListTile(
          leading: const Icon(Icons.notifications),
          title: const Text('Notification Preferences'),
          onTap: () => _navigateToNotifications(context),
        ),
        ListTile(
          leading: const Icon(Icons.privacy_tip),
          title: const Text('Privacy Settings'),
          onTap: () => _navigateToPrivacy(context),
        ),
      ],
    );
  }

  Widget _buildProfileHeader(BuildContext context, User? user) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(25),
              backgroundImage: user?.photoUrl != null
                  ? NetworkImage(user!.photoUrl!)
                  : null,
              child: user?.photoUrl == null
                  ? Text(
                      user?.name.isNotEmpty == true ? user!.name[0] : '?',
                      style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.name ?? 'Guest User',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? 'user@example.com',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        user?.isAdmin == true ? 'Admin' : 'Gold Member',
                        style: TextStyle(
                          fontSize: 14,
                          color: user?.isAdmin == true 
                              ? Colors.deepPurple 
                              : Colors.amber,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      childAspectRatio: 0.9,
      children: [
        _buildQuickActionButton(
          context,
          icon: Icons.history,
          label: 'History',
          onTap: () => _navigateToBookingHistory(context),
        ),
        _buildQuickActionButton(
          context,
          icon: Icons.favorite,
          label: 'Favorites',
          onTap: () => _navigateToFavorites(context),
        ),
        _buildQuickActionButton(
          context,
          icon: Icons.card_membership,
          label: 'Loyalty',
          onTap: () => _navigateToLoyalty(context),
        ),
        _buildQuickActionButton(
          context,
          icon: Icons.settings,
          label: 'Settings',
          onTap: () => _tabController.animateTo(1), // Switch to Settings tab
        ),
      ],
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoSection(User? user) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Personal Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ProfileInfoRow(
              title: 'Date of Birth',
              value: user?.birthDate ?? 'Not set',
              icon: Icons.cake,
            ),
            ProfileInfoRow(
              title: 'Location',
              value: user?.location ?? 'Not set',
              icon: Icons.location_on,
            ),
            ProfileInfoRow(
              title: 'Phone',
              value: user?.phone ?? 'Not set',
              icon: Icons.phone,
            ),
            ProfileInfoRow(
              title: 'Bio',
              value: user?.bio ?? 'Not set',
              icon: Icons.info,
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Activity',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildActivityItem(
              icon: Icons.hotel,
              title: 'Booked Sunset Paradise Resort',
              subtitle: 'December 15-20, 2023',
              color: Colors.green,
            ),
            _buildActivityItem(
              icon: Icons.star,
              title: 'Earned Gold Status',
              subtitle: 'December 1, 2023',
              color: Colors.amber,
            ),
            _buildActivityItem(
              icon: Icons.thumb_up,
              title: 'Liked Mountain View Lodge',
              subtitle: 'November 28, 2023',
              color: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        decoration: BoxDecoration(
          color: color.withAlpha(25),
          shape: BoxShape.circle,
        ),
        padding: const EdgeInsets.all(8),
        child: Icon(icon, color: color),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
    );
  }

  Widget _buildAccountManagement(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Account Management',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildAccountOption(
              context,
              icon: Icons.payment,
              title: 'Payment Methods',
              onTap: () => _navigateToPaymentMethods(context),
            ),
            _buildAccountOption(
              context,
              icon: Icons.security,
              title: 'Security',
              onTap: () => _navigateToSecurity(context),
            ),
            _buildAccountOption(
              context,
              icon: Icons.notifications,
              title: 'Notification Preferences',
              onTap: () => _navigateToNotifications(context),
            ),
            _buildAccountOption(
              context,
              icon: Icons.privacy_tip,
              title: 'Privacy Settings',
              onTap: () => _navigateToPrivacy(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward),
      onTap: onTap,
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return ButtonWidget.filled(
      text: 'Log Out',
      onPressed: () => _showLogoutConfirmation(context),
      backgroundColor: Colors.redAccent,
      foregroundColor: Colors.white,
      isFullWidth: true,
    );
  }

  // Navigation methods
  void _navigateToEditProfile(BuildContext context) {
    // Implement navigation to edit profile screen
    // Navigator.push(context, MaterialPageRoute(builder: (_) => EditProfileScreen()));
  }

  void _navigateToBookingHistory(BuildContext context) {
    // Implement navigation to booking history
  }

  void _navigateToFavorites(BuildContext context) {
    // Implement navigation to favorites
  }

  void _navigateToLoyalty(BuildContext context) {
    // Implement navigation to loyalty program
  }

  void _navigateToPaymentMethods(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentScreen.mock(
          amount: 0.0,
          onPaymentSuccess: () {}, // Dummy callback
        ),
      ),
    );
  }

  void _navigateToSecurity(BuildContext context) {
    // Implement navigation to security settings
  }

  void _navigateToNotifications(BuildContext context) {
    // Implement navigation to notification preferences
  }

  void _navigateToPrivacy(BuildContext context) {
    // Implement navigation to privacy settings
  }

  void _showChangePasswordDialog(BuildContext context) {
    final newPasswordController = TextEditingController();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: TextField(
          controller: newPasswordController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'New Password',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await userProvider.changePassword(newPasswordController.text);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Password changed successfully')),
              );
            },
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              userProvider.logout();
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const WelcomeScreen()),
              );
            },
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }
}
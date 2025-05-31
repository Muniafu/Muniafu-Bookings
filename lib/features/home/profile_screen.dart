import 'package:flutter/material.dart';
import 'package:muniafu/data/models/user.dart';
import 'package:provider/provider.dart';
import 'payment_screen.dart';
import 'package:muniafu/providers/auth_provider.dart';
import 'package:muniafu/features/authentication/screens/welcome_screen.dart';
import 'package:muniafu/app/core/widgets/button_widget.dart';
import 'package:muniafu/features/home/widgets/profile_info_row.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Profile'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _navigateToEditProfile(context),
            tooltip: 'Edit Profile',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
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
            
            // Social Links Section
            _buildSocialLinks(),
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
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, User? user) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              child: user?.name.isNotEmpty == true
                  ? Text(
                      user!.name[0],
                      style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                    )
                  : const Icon(Icons.person, size: 40),
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
                      Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        user?.role == 'admin' ? 'Admin' : 'Gold Member',
                        style: TextStyle(
                          fontSize: 14,
                          color: user?.role == 'admin' 
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
          onTap: () => _navigateToSettings(context),
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
        padding: const EdgeInsets.all(16.0),
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
              value: user?.location ?? 'Nairobi, Kenya',
              icon: Icons.location_on,
            ),
            ProfileInfoRow(
              title: 'Phone',
              value: user?.phone ?? '+254 712 345 678',
              icon: Icons.phone,
            ),
            ProfileInfoRow(
              title: 'Bio',
              value: user?.bio ?? 'Frequent traveler and hotel enthusiast',
              icon: Icons.info,
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialLinks() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Social Connections',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSocialButton(
                  icon: Icons.facebook,
                  label: 'Facebook',
                  color: const Color(0xFF1877F2),
                ),
                _buildSocialButton(
                  icon: Icons.email,
                  label: 'Email',
                  color: Colors.red,
                ),
                _buildSocialButton(
                  icon: Icons.link,
                  label: 'Website',
                  color: Colors.blueGrey,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(12),
          child: Icon(icon, size: 30, color: color),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildRecentActivity() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
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
          color: color.withOpacity(0.1),
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
        padding: const EdgeInsets.all(16.0),
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
    // Navigate to edit profile screen
  }

  void _navigateToBookingHistory(BuildContext context) {
    // Navigate to booking history
  }

  void _navigateToFavorites(BuildContext context) {
    // Navigate to favorites
  }

  void _navigateToLoyalty(BuildContext context) {
    // Navigate to loyalty program
  }

  void _navigateToSettings(BuildContext context) {
    // Navigate to settings
  }

  void _navigateToPaymentMethods(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PaymentScreen(
          amount: 0.0,
          bookingId: 'profile_management',
          currency: 'USD',
          bookingDetails: {},
        ),
      ),
    );
  }

  void _navigateToSecurity(BuildContext context) {
    // Navigate to security settings
  }

  void _navigateToNotifications(BuildContext context) {
    // Navigate to notification preferences
  }

  void _navigateToPrivacy(BuildContext context) {
    // Navigate to privacy settings
  }

  void _showLogoutConfirmation(BuildContext context) {
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
              Navigator.pop(context);
              Provider.of<AuthProvider>(context, listen: false).logout();
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
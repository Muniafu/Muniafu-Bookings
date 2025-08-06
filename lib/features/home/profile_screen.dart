import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/core/widgets/button_widget.dart';
import '../../data/models/user.dart';
import '../home/widgets/profile_info_row.dart';
import '../../providers/auth_provider.dart';
import '../authentication/screens/welcome_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserData();
  }

  void _loadUserData() {
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    if (user != null) {
      _fullNameController.text = user.name;
      _phoneController.text = user.phone ?? '';
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Profile'),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _tabController.animateTo(1),
              tooltip: 'Edit Profile',
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(icon: Icon(Icons.person)),
              Tab(icon: Icon(Icons.settings)),
            ],
          ),
        ),
        body: user == null
            ? const Center(child: Text('User not logged in'))
            : TabBarView(
                controller: _tabController,
                children: [
                  // Profile Overview Tab
                  _buildOverviewTab(context, user),
                  // Edit Profile Tab
                  _buildEditProfileTab(context, authProvider),
                ],
              ),
      ),
    );
  }

  Widget _buildOverviewTab(BuildContext context, User user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Profile Header
          _buildProfileHeader(context, user),
          const SizedBox(height: 24),
          
          // Quick Actions
          _buildQuickActions(context),
          const SizedBox(height: 24),
          
          // Personal Information
          _buildPersonalInfoSection(user),
          const SizedBox(height: 24),
          
          // Recent Activity
          _buildRecentActivity(),
          const SizedBox(height: 24),
          
          // Account Management
          _buildAccountManagement(context),
          const SizedBox(height: 24),
          
          // Logout Button
          _buildLogoutButton(context),
        ],
      ),
    );
  }

  Widget _buildEditProfileTab(BuildContext context, AuthProvider authProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Profile Picture
            _buildProfilePicture(context),
            const SizedBox(height: 24),
            
            // Email (read-only)
            TextFormField(
              enabled: false,
              initialValue: authProvider.currentUser?.email,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            
            // Full Name
            TextFormField(
              controller: _fullNameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
              validator: (val) => val!.isEmpty ? 'Enter full name' : null,
            ),
            const SizedBox(height: 16),
            
            // Phone
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone',
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
              validator: (val) => val!.isEmpty ? 'Enter phone number' : null,
            ),
            const SizedBox(height: 24),
            
            // Save Button
            ButtonWidget.filled(
              text: 'Save Changes',
              isLoading: authProvider.isLoading,
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  await authProvider.updateProfile(
                    name: _fullNameController.text.trim(),
                    phone: _phoneController.text.trim(),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profile updated successfully')),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, User user) {
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
              backgroundImage: user.photoUrl != null
                  ? NetworkImage(user.photoUrl!)
                  : null,
              child: user.photoUrl == null
                  ? Text(
                      user.name.isNotEmpty ? user.name[0] : '?',
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
                    user.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
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
                        user.isAdmin ? 'Admin' : 'Member',
                        style: TextStyle(
                          fontSize: 14,
                          color: user.isAdmin 
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

  Widget _buildProfilePicture(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(25),
            child: const Icon(Icons.person, size: 60),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(8),
              child: const Icon(Icons.edit, color: Colors.white, size: 20),
            ),
          ),
        ],
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
          onTap: () => _tabController.animateTo(1),
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

  Widget _buildPersonalInfoSection(User user) {
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
              title: 'Email',
              value: user.email,
              icon: Icons.email,
            ),
            ProfileInfoRow(
              title: 'Phone',
              value: user.phone ?? 'Not set',
              icon: Icons.phone,
            ),
            ProfileInfoRow(
              title: 'Location',
              value: user.location ?? 'Not set',
              icon: Icons.location_on,
            ),
            ProfileInfoRow(
              title: 'Member Since',
              value: user.createdAt.toLocal().toString().split(' ')[0],
              icon: Icons.calendar_today,
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
              title: 'Last Booking',
              subtitle: 'December 15-20, 2023',
              color: Colors.green,
            ),
            _buildActivityItem(
              icon: Icons.star,
              title: 'Reward Points',
              subtitle: '1,250 points available',
              color: Colors.amber,
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
                'Account Settings',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text('Change Password'),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () => _showChangePasswordDialog(context),
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Notification Preferences'),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () => _navigateToNotifications(context),
            ),
            ListTile(
              leading: const Icon(Icons.privacy_tip),
              title: const Text('Privacy Settings'),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () => _navigateToPrivacy(context),
            ),
          ],
        ),
      ),
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

  // Navigation and Dialog Methods
  void _navigateToBookingHistory(BuildContext context) {
    // Implement navigation
  }

  void _navigateToFavorites(BuildContext context) {
    // Implement navigation
  }

  void _navigateToLoyalty(BuildContext context) {
    // Implement navigation
  }

  void _navigateToNotifications(BuildContext context) {
    // Implement navigation
  }

  void _navigateToPrivacy(BuildContext context) {
    // Implement navigation
  }

  void _showChangePasswordDialog(BuildContext context) {
    final newPasswordController = TextEditingController();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
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
              await authProvider.changePassword(newPasswordController.text);
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
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
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
            onPressed: () async {
              await authProvider.logout();
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
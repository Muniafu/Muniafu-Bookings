import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null) {
      _nameController.text = user.name;
      _phoneController.text = user.phone ?? '';
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.user;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _confirmLogout(context, auth),
          )
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'View'),
            Tab(text: 'Edit'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildViewTab(context, user),
          _buildEditTab(context, auth),
        ],
      ),
    );
  }

  Widget _buildViewTab(BuildContext context, user) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Center(
          child: Stack(
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey,
                child: Icon(Icons.person, size: 50, color: Colors.white),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: Theme.of(context).primaryColor,
                  child: const Icon(Icons.edit, size: 16, color: Colors.white),
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildInfoCard(Icons.person, "Name", user.name),
        _buildInfoCard(Icons.email, "Email", user.email),
        _buildInfoCard(Icons.phone, "Phone", user.phone ?? 'Not set'),
        _buildInfoCard(Icons.verified_user, "Role", user.role),
        const SizedBox(height: 30),
        _buildGridActions(context),
      ],
    );
  }

  Widget _buildInfoCard(IconData icon, String title, String value) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(value),
      ),
    );
  }

  Widget _buildGridActions(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      children: [
        _gridItem(context, Icons.favorite, "Wishlist", '/wishlist'),
        _gridItem(context, Icons.book_online, "Bookings", '/my-bookings'),
        _gridItem(context, Icons.reviews, "Reviews", ''), // Add route if needed
      ],
    );
  }

  Widget _gridItem(BuildContext context, IconData icon, String label, String route) {
    return InkWell(
      onTap: route.isNotEmpty ? () => Navigator.pushNamed(context, route) : null,
      child: Card(
        elevation: 2,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 30, color: Theme.of(context).primaryColor),
              const SizedBox(height: 8),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditTab(BuildContext context, AuthProvider auth) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                children: [
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Full Name'),
                    validator: (value) => value == null || value.isEmpty ? 'Name required' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(labelText: 'Phone'),
                    keyboardType: TextInputType.phone,
                    validator: (value) => value == null || value.isEmpty ? 'Phone required' : null,
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: () => _saveChanges(context, auth),
                    icon: const Icon(Icons.save),
                    label: const Text("Save Changes"),
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> _saveChanges(BuildContext context, AuthProvider auth) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      await auth.updateUserProfile(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated successfully")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.toString()}")),
        );
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _confirmLogout(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text("Logout"),
            onPressed: () {
              auth.signOut();
              Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
            },
          ),
        ],
      ),
    );
  }
}
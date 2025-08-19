import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../admin/admin_dashboard_screen.dart';
import '../home/home_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isLoading = false;
  String selectedRole = 'user';
  List<String> roles = ['user', 'admin'];

  @override
  void initState() {
    super.initState();
    _fetchRolesFromFirestore();
  }

  Future<void> _fetchRolesFromFirestore() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('roles').get();
      if (snapshot.docs.isNotEmpty) {
        setState(() {
          roles = snapshot.docs.map((doc) => doc.id).toList();
          if (!roles.contains('user')) roles.insert(0, 'user');
        });
      }
    } catch (e) {
      debugPrint('Failed to fetch roles: $e');
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);

      await auth.signUp(
        emailController.text.trim(),
        passwordController.text.trim(),
        nameController.text.trim(),
      );

      final user = auth.user;

      if (user != null) {
        // Set role in Firestore
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'role': selectedRole,
          'phone': phoneController.text.trim(),
        });

        // Navigate based on role
        if (selectedRole == 'admin') {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminDashboardScreen()));
        } else {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Registration failed: ${e.toString()}")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Create Account")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Icon(Icons.hotel, size: 60, color: Colors.indigo),
              const SizedBox(height: 20),
              Text("Join Us!", style: theme.textTheme.titleLarge?.copyWith(color: Colors.indigo)),
              const SizedBox(height: 30),

              // Full Name
              CustomTextField(
                controller: nameController,
                label: "Full Name",
                icon: Icons.person,
                validator: (v) => v == null || v.isEmpty ? "Enter your name" : null,
              ),
              const SizedBox(height: 15),

              // Email
              CustomTextField(
                controller: emailController,
                label: "Email",
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                validator: (v) => v == null || !v.contains('@') ? "Enter valid email" : null,
              ),
              const SizedBox(height: 15),

              // Phone
              CustomTextField(
                controller: phoneController,
                label: "Phone",
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
                validator: (v) => v == null || v.length < 10 ? "Enter valid phone number" : null,
              ),
              const SizedBox(height: 15),

              // Password
              CustomTextField(
                controller: passwordController,
                label: "Password",
                icon: Icons.lock,
                obscureText: true,
                validator: (v) => v == null || v.length < 6 ? "Minimum 6 characters" : null,
              ),
              const SizedBox(height: 15),

              // Confirm Password
              CustomTextField(
                controller: confirmPasswordController,
                label: "Confirm Password",
                icon: Icons.lock_outline,
                obscureText: true,
                validator: (v) {
                  if (v != passwordController.text) return "Passwords don't match";
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Role Dropdown
              DropdownButtonFormField<String>(
                value: selectedRole,
                items: roles
                    .map((role) => DropdownMenuItem(value: role, child: Text(role.toUpperCase())))
                    .toList(),
                onChanged: (val) => setState(() => selectedRole = val ?? 'user'),
                decoration: const InputDecoration(labelText: "Register as", prefixIcon: Icon(Icons.verified_user)),
              ),
              const SizedBox(height: 30),

              // Sign Up Button
              CustomButton(
                label: "Sign Up",
                onPressed: isLoading ? null : _register,
                isLoading: isLoading,
              ),

              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                child: const Text("Already have an account? Login"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
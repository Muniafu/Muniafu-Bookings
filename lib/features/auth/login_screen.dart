import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _showPassword = false;
  String? _emailError;
  String? _passError;

  Future<void> _login() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    setState(() {
      _emailError = null;
      _passError = null;
    });

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await auth.signIn(emailController.text.trim(), passController.text.trim());

      // Redirect based on role
      if (auth.isAdmin) {
        Navigator.pushReplacementNamed(context, '/admin');
      } else {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 40),
              const Icon(Icons.hotel, size: 60, color: Colors.indigo),
              const SizedBox(height: 20),
              Text("Welcome Back!", style: theme.textTheme.titleLarge?.copyWith(color: Colors.indigo)),
              const SizedBox(height: 30),

              // Email
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: "Email",
                  prefixIcon: const Icon(Icons.email),
                  errorText: _emailError,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return "Enter your email";
                  if (!value.contains("@")) return "Enter a valid email";
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Password
              TextFormField(
                controller: passController,
                obscureText: !_showPassword,
                decoration: InputDecoration(
                  labelText: "Password",
                  prefixIcon: const Icon(Icons.lock),
                  errorText: _passError,
                  suffixIcon: IconButton(
                    icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _showPassword = !_showPassword),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return "Enter your password";
                  if (value.length < 6) return "Password must be at least 6 characters";
                  return null;
                },
              ),
              const SizedBox(height: 30),

              // Login Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  child: _isLoading
                      ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text("Login"),
                ),
              ),

              TextButton(
                onPressed: () => Navigator.pushReplacementNamed(context, '/signup'),
                child: const Text("Don't have an account? Sign up"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
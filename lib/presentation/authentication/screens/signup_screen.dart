import 'package:flutter/material.dart';
import 'package:muniafu/presentation/authentication/widgets/background_widget.dart';
import 'package:muniafu/presentation/authentication/widgets/button_widget.dart';
import 'package:muniafu/presentation/authentication/widgets/logo_widget.dart';
import 'package:muniafu/services/auth_service.dart';
import 'package:muniafu/presentation/authentication/screens/login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundWidget(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const LogoWidget(imagePath: './assets/images/onboarding3.png'),
              const SizedBox(height: 20),
              const Text('Signup', style: TextStyle(fontSize: 24)),
              const SizedBox(height: 20),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              ButtonWidget(
                text: 'Signup',
                onPressed: () async {
                  try {
                    // Call the registerUser method from AuthService
                    await _authService.registerUser(
                      _emailController.text,
                      _passwordController.text,
                      _nameController.text,
                      'role', // Adjust 'role' as needed
                    );

                    // Navigate to the login screen after successful signup
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );

                    // Optionally, show a success message
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Signup successful! Please login.')),
                    );
                  } catch (e) {
                    // Show an error message if signup fails
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Signup failed: $e')),
                    );
                  }
                },
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                },
                child: const Text(
                  'Already signed up? Login',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
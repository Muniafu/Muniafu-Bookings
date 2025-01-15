import 'package:flutter/material.dart';
import 'package:muniafu/presentation/authentication/screens/forget_password_screen.dart';
import 'package:muniafu/presentation/authentication/widgets/background_widget.dart';
import 'package:muniafu/presentation/authentication/widgets/button_widget.dart';
import 'package:muniafu/presentation/authentication/widgets/logo_widget.dart';
import 'package:muniafu/presentation/dashboard/dashboard_screen.dart';
import 'package:muniafu/services/auth_service.dart';
import 'package:muniafu/presentation/authentication/screens/signup_screen.dart';

// Login Screen for user
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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
              const LogoWidget(imagePath: './assets/images/onboarding2.png'),
              const SizedBox(height: 20),
              const Text('Login', style: TextStyle(fontSize: 24)),
              const SizedBox(height: 20),
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
                text: 'Login',
                onPressed: () async {
                  try {
                    // Call the loginUser method from AuthService
                    await _authService.loginUser(
                      _emailController.text,
                      _passwordController.text,
                    );

                    // Navigate to the HomeScreen on successful login
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) =>  const DashboardScreen()),
                    );

                    // Optionally, show a success message
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Login successful! Welcome to the app.')),
                    );
                  } catch (e) {
                    // Show an error message if login fails
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Login failed: $e')),
                    );
                  }
                },
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  // Replace with actual ForgotPasswordScreen when available
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => ForgetPasswordScreen(),
                    )
                  );
                },
                child: const Text('Forgot Password'),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  // Navigate to the SignupScreen
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SignupScreen()),
                  );
                },
                child: const Text(
                  'Not Registered? Signup',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
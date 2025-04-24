import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:muniafu/app/core/widgets/background_widget.dart';
import 'package:muniafu/app/core/widgets/button_widget.dart';
import 'package:muniafu/app/core/widgets/logo_widget.dart';
import 'package:muniafu/features/dashboard/dashboard_screen.dart';
import 'package:muniafu/features/authentication/screens/forget_password_screen.dart';
import 'package:muniafu/features/authentication/screens/signup_screen.dart';
import 'package:muniafu/providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: BackgroundWidget(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const LogoWidget(imagePath: './assets/images/onboarding2.png'),
                  const SizedBox(height: 20),
                  Text(
                    'Login',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    validator: (val) => val != null && val.contains('@')
                        ? null
                        : 'Enter a valid email',
                    onChanged: (val) => _emailController.text = val,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: (val) => val != null && val.length >= 6
                        ? null
                        : 'Password must be 6+ characters',
                    onChanged: (val) => _passwordController.text = val,
                  ),
                  const SizedBox(height: 24),
                  if (authProvider.isLoading)
                    const CircularProgressIndicator(),
                  if (!authProvider.isLoading)
                    ButtonWidget(
                      text: 'Login',
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          await authProvider.login(
                            _emailController.text.trim(),
                            _passwordController.text.trim(),
                          );

                          if (authProvider.error != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(authProvider.error!)),
                            );
                          } else {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const DashboardScreen(),
                              ),
                            );
                          }
                        }
                      },
                    ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ForgetPasswordScreen(),
                      ),
                    ),
                    child: const Text('Forgot Password?'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SignupScreen(),
                      ),
                    ),
                    child: const Text(
                      "Don't have an account? Sign up",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
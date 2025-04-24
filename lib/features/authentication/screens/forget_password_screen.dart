import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:muniafu/app/core/widgets/background_widget.dart';
import 'package:muniafu/app/core/widgets/button_widget.dart';
import 'package:muniafu/app/core/widgets/logo_widget.dart';
import 'package:muniafu/providers/auth_provider.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
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
                  const LogoWidget(imagePath: './assets/images/onboarding.png'),
                  const SizedBox(height: 20),
                  Text(
                    'Reset Password',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Enter your email to receive a password reset link',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    validator: (val) => val != null && val.contains('@')
                        ? null
                        : 'Enter a valid email',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 24),
                  if (authProvider.isLoading)
                    const CircularProgressIndicator(),
                  if (!authProvider.isLoading)
                    ButtonWidget(
                      text: 'Send Reset Link',
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          final result = await authProvider
                              .sendPasswordResetEmail(_emailController.text.trim());
                          
                          if (result != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(result)),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Password reset link sent to your email'),
                              ),
                            );
                            Navigator.pop(context);
                          }
                        }
                      },
                    ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Back to Login',
                      style: TextStyle(color: Colors.black),
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
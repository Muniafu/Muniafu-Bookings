import 'package:flutter/material.dart';
import 'package:muniafu/presentation/authentication/widgets/background_widget.dart';
import 'package:muniafu/presentation/authentication/widgets/button_widget.dart';
import 'package:muniafu/presentation/authentication/widgets/logo_widget.dart';
import 'package:muniafu/services/auth_service.dart';

class ForgetPasswordScreen extends StatelessWidget{
  final TextEditingController _emailController = TextEditingController();
  final AuthService _authService = AuthService();

  ForgetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundWidget(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const LogoWidget(imagePath: './assets/images/'),
              const SizedBox(height: 20),
              const Text('Reset Password', style: TextStyle(fontSize: 24)),
              const SizedBox(height: 20),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 20),
              ButtonWidget(
                text: 'Send Reset Link', 
                onPressed: () async {
                  try {
                    await _authService.resetPassword(_emailController.text);

                    // Notify user of success
                  } catch (e) {
                    // Handle error
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension on AuthService {
  resetPassword(String text) {}
}
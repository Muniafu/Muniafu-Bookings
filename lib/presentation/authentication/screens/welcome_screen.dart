import 'package:flutter/material.dart';
import 'package:muniafu/presentation/authentication/screens/login_screen.dart';
import 'package:muniafu/presentation/authentication/screens/signup_screen.dart';
import 'package:muniafu/presentation/authentication/widgets/background_widget.dart';
import 'package:muniafu/presentation/authentication/widgets/button_widget.dart';
import 'package:muniafu/presentation/authentication/widgets/logo_widget.dart';

// Welcome screen for initial navigation to login or sign up
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: BackgroundWidget(
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Logo and welcome text section
              Column(
                children: [
                  SizedBox(height: screenHeight * 0.1), // Add top padding
                  const LogoWidget(imagePath: './assets/images/onboarding.png'),
                  const SizedBox(height: 20),
                  const Text(
                    'Welcome to Bookings App',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              // Buttons section
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.1, // Side padding
                  vertical: screenHeight * 0.05, // Bottom padding
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: ButtonWidget(
                        text: 'Login',
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20), // Space between buttons
                    Expanded(
                      child: ButtonWidget(
                        text: 'Signup',
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SignupScreen()),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

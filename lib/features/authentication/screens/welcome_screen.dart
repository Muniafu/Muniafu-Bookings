import 'package:flutter/material.dart';
import 'package:muniafu/features/authentication/screens/login_screen.dart';
import 'package:muniafu/features/authentication/screens/signup_screen.dart';
import 'package:muniafu/app/core/widgets/background_widget.dart';
import 'package:muniafu/app/core/widgets/button_widget.dart';
import 'package:muniafu/app/core/widgets/logo_widget.dart';

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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo and welcome text section
              Column(
                children: [
                  const LogoWidget(imagePath: './assets/images/onboarding.png'),
                  const SizedBox(height: 20),
                  Text(
                    'Welcome to HotelEase',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Book your perfect stay with ease',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),

              // Buttons section
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.1,
                  vertical: screenHeight * 0.05,
                ),
                child: Column(
                  children: [
                    ButtonWidget(
                      text: 'Login',
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ButtonWidget(
                      text: 'Sign Up',
                      variant: ButtonVariant.outlined,
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SignupScreen()),
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
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:muniafu/features/authentication/screens/login_screen.dart';
import 'package:muniafu/features/authentication/screens/signup_screen.dart';
import 'package:muniafu/app/core/widgets/background_widget.dart';
import 'package:muniafu/app/core/widgets/button_widget.dart';
import 'package:muniafu/app/core/widgets/logo_widget.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;
  late bool _isDarkMode;

  @override
  void initState() {
    super.initState();
    
    // Get current system theme
    _isDarkMode = SchedulerBinding.instance.window.platformBrightness == Brightness.dark;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  void _navigateToLogin(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const LoginScreen(),
        transitionsBuilder: (_, a, __, c) => 
          FadeTransition(opacity: a, child: c),
      ),
    );
  }

  void _navigateToSignup(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const SignupScreen(),
        transitionsBuilder: (_, a, __, c) => 
          FadeTransition(opacity: a, child: c),
      ),
    );
  }

  void _showTermsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms & Conditions'),
        content: SingleChildScrollView(
          child: Text(
            'By using our hotel booking app, you agree to our Terms of Service and Privacy Policy. '
            'We are committed to protecting your personal information and ensuring a '
            'secure booking experience. Your data will only be used to facilitate your '
            'bookings and improve your experience with us.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ACCEPT'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screenSize = MediaQuery.of(context).size;
    final isPortrait = screenSize.height > screenSize.width;

    return Theme(
      data: _isDarkMode 
          ? ThemeData.dark().copyWith(
              colorScheme: ColorScheme.fromSwatch().copyWith(
                primary: Colors.tealAccent,
                secondary: Colors.amber,
              ),
            )
          : ThemeData.light().copyWith(
              colorScheme: ColorScheme.fromSwatch().copyWith(
                primary: Colors.deepPurple,
                secondary: Colors.amber,
              ),
            ),
      child: Scaffold(
        body: BackgroundWidget(
          child: SafeArea(
            child: Stack(
              children: [
                // Theme Toggle Button
                Positioned(
                  top: 16,
                  right: 16,
                  child: IconButton(
                    icon: Icon(
                      _isDarkMode ? Icons.light_mode : Icons.dark_mode,
                      color: colorScheme.secondary,
                    ),
                    onPressed: _toggleTheme,
                    tooltip: _isDarkMode ? 'Switch to light mode' : 'Switch to dark mode',
                  ),
                ),
                
                // Main Content
                Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: isPortrait 
                          ? screenSize.width * 0.1 
                          : screenSize.width * 0.2,
                      vertical: 16,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Animated Logo and Tagline
                        FadeTransition(
                          opacity: _opacityAnimation,
                          child: Column(
                            children: [
                              const Hero(
                                tag: 'app-logo',
                                child: LogoWidget(
                                  imagePath: './assets/images/logo.png',
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'StayEase',
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 40),
                        
                        // Slide Animation for Content
                        SlideTransition(
                          position: _slideAnimation,
                          child: Column(
                            children: [
                              Text(
                                'Find Your Perfect Stay',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onBackground,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Discover and book hotels at the best prices with instant confirmation',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: colorScheme.onSurface.withOpacity(0.7),
                                  height: 1.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 40),
                              
                              // Buttons
                              ButtonWidget.filled(
                                text: 'Login',
                                onPressed: () => _navigateToLogin(context),
                                isFullWidth: true,
                              ),
                              const SizedBox(height: 16),
                              ButtonWidget.outlined(
                                text: 'Sign Up',
                                onPressed: () => _navigateToSignup(context),
                                isFullWidth: true,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Terms & Service
                Positioned(
                  bottom: 24,
                  left: 0,
                  right: 0,
                  child: FadeTransition(
                    opacity: _opacityAnimation,
                    child: Center(
                      child: GestureDetector(
                        onTap: () => _showTermsDialog(context),
                        child: Text(
                          'Terms of Service & Privacy Policy',
                          style: TextStyle(
                            color: colorScheme.onSurface.withOpacity(0.6),
                            decoration: TextDecoration.underline,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
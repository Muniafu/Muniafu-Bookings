import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import '../../../app/core/widgets/background_widget.dart';
import '../../../app/core/widgets/button_widget.dart';
import '../../../app/core/widgets/logo_widget.dart';
import 'login_screen.dart';
import 'signup_screen.dart';
import '../../../providers/auth_provider.dart';
import '../../dashboard/admin_analytics_screen.dart';
import '../../home/home_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _errorOccurred = false;
  bool _navigated = false;
  bool _showAuthOptions = false;

  @override
  void initState() {
    super.initState();

    // Logo animation controller
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..forward();

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    // Check auth state after animation completes
    Future.delayed(const Duration(seconds: 2), () {
      _checkAuthState();
      // Show auth options if not auto-navigating
      Future.delayed(const Duration(seconds: 1), () {
        if (!_navigated) {
          setState(() => _showAuthOptions = true);
        }
      });
    });
  }

  Future<void> _checkAuthState() async {
    if (_navigated) return;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      await authProvider.loadCurrentUser();
      final user = authProvider.currentUser;

      if (mounted) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (!_navigated) {
            _navigated = true;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => user == null 
                  ? const LoginScreen() 
                  : authProvider.isAdmin 
                    ? const AdminAnalyticsScreen() 
                    : const HomeScreen(),
              ),
            );
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorOccurred = true);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: BackgroundWidget(
        child: Center(
          child: _errorOccurred 
            ? _buildErrorState(theme)
            : AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: _showAuthOptions
                  ? _buildAuthOptions()
                  : ScaleTransition(
                      scale: _scaleAnimation,
                      child: _buildWelcomeContent(theme),
                    ),
              ),
        ),
      ),
    );
  }

  Widget _buildWelcomeContent(ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const LogoWidget(imagePath: "assets/images/logo.png", size: 120),
        const SizedBox(height: 24),
        Text(
          "Welcome to Hotelify",
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 12),
        if (!_showAuthOptions) const CircularProgressIndicator(),
      ],
    );
  }

  Widget _buildAuthOptions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const LogoWidget(imagePath: "assets/images/logo.png", size: 100),
          const SizedBox(height: 40),
          Text(
            'Welcome to Hotelify',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 40),
          ButtonWidget(
            text: 'Login',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SignupScreen()),
            ),
            child: const Text('Sign Up'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
        const SizedBox(height: 16),
        Text(
          "Something went wrong",
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        ButtonWidget(
          text: "Try again",
          icon: const Icon(Icons.refresh),
          onPressed: () {
            setState(() {
              _errorOccurred = false;
              _navigated = false;
            });
            _checkAuthState();
          },
        ),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import 'package:muniafu/data/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:muniafu/providers/auth_provider.dart';
import 'package:muniafu/app/core/widgets/background_widget.dart';
import 'package:muniafu/app/core/widgets/button_widget.dart';
import 'package:muniafu/app/core/widgets/logo_widget.dart';
import 'package:muniafu/features/authentication/screens/login_screen.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isSuccess = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;
    
    final authProvider = context.read<AuthProvider>();
    FocusScope.of(context).unfocus(); // Dismiss keyboard
    
    try {
      await authProvider.sendPasswordResetEmail(
        _emailController.text.trim(),
      );
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset link sent to your email'),
          backgroundColor: Colors.green,
        ),
      );
      
      setState(() => _isSuccess = true);
      
      // Auto-navigate back after success
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) Navigator.pop(context);
      });
    } catch (e) {
      // Show error in snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e is AuthException ? e.message : 'Failed to send reset link'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  const SizedBox(height: 40),
                  const LogoWidget(imagePath: './assets/images/forget.png'),
                  const SizedBox(height: 30),
                  Text(
                    _isSuccess ? 'Check Your Email' : 'Reset Password',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                  const SizedBox(height: 10),
                  _isSuccess 
                    ? _buildSuccessContent()
                    : _buildResetForm(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessContent() {
    return Column(
      children: [
        const SizedBox(height: 20),
        const Icon(Icons.check_circle, color: Colors.green, size: 80),
        const SizedBox(height: 20),
        Text(
          'We\'ve sent a password reset link to your email address',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 30),
        const CircularProgressIndicator(),
        const SizedBox(height: 20),
        Text(
          'Redirecting to login...',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildResetForm(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    
    return Column(
      children: [
        const SizedBox(height: 10),
        Text(
          'Enter your email to receive a password reset link',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 30),
        _buildEmailField(),
        const SizedBox(height: 30),
        ButtonWidget(
          text: 'Send Reset Link',
          isLoading: authProvider.isLoading,
          onPressed: authProvider.isLoading ? null : () => _handleResetPassword(context),
        ),
        const SizedBox(height: 20),
        TextButton(
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          ),
          child: Text(
            'Back to Login',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      decoration: InputDecoration(
        labelText: 'Email Address',
        prefixIcon: const Icon(Icons.email),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
      ),
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.done,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your email';
        }
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return 'Please enter a valid email';
        }
        return null;
      },
      onFieldSubmitted: (_) => _handleResetPassword(context),
    );
  }
}
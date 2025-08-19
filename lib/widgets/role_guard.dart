import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class RoleGuard extends StatelessWidget {
  final Widget child;
  final String requiredRole;
  final Widget? fallback;

  const RoleGuard({
    super.key,
    required this.child,
    required this.requiredRole,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final role = auth.user?.role;

    if (role == requiredRole) {
      return child;
    }

    return fallback ?? const AccessDeniedScreen();
  }
}

class AccessDeniedScreen extends StatelessWidget {
  const AccessDeniedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text("Access Denied", style: TextStyle(fontSize: 20, color: Colors.red)),
      ),
    );
  }
}
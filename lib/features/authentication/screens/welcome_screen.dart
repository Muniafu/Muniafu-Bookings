import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:muniafu/features/authentication/screens/login_screen.dart';
import 'package:muniafu/features/authentication/screens/signup_screen.dart';
import 'package:muniafu/app/core/widgets/background_widget.dart';
import 'package:muniafu/app/core/widgets/button_widget.dart';
import 'package:muniafu/app/core/widgets/logo_widget.dart';

import '../../../providers/auth_provider.dart';
import '../../dashboard/admin_analytics_screen.dart';
import '../../home/home_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Provider.of<AuthProvider>(context, listen: false).fetchUserRole(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final isAdmin = Provider.of<AuthProvider>(context, listen: false).isAdmin;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => isAdmin ? const AdminAnalyticsScreen() : const HomeScreen()),
          );
        });

        return const Scaffold(body: SizedBox()); // temporary blank during redirect
      },
    );
  }
}
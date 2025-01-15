import 'package:flutter/material.dart';
import 'package:muniafu/presentation/authentication/widgets/background_widget.dart';

class AdminScreen extends StatelessWidget{
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: BackgroundWidget(
        child: Center(
          child: Text('Admin Dashboard'),
        ),
      ),
    );
  }
}
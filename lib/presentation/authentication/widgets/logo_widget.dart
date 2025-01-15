import 'package:flutter/material.dart';

// Display the app's logo
class LogoWidget extends StatelessWidget{
  final String imagePath;

  const LogoWidget({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      imagePath,
      height: 100,
      width: 100,
      fit: BoxFit.contain,
    );
  }
}
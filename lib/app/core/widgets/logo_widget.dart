import 'package:flutter/material.dart';

class LogoWidget extends StatelessWidget {
  final String imagePath;
  final double size;

  const LogoWidget({
    super.key,
    required this.imagePath,
    this.size = 100,
  });

  @override
  Widget build(BuildContext context) {
    return imagePath.startsWith('http')
        ? Image.network(
          imagePath,
          width: size,
          height: size,
        )
        : Image.asset(
          imagePath,
          width: size,
          height: size,
        );
  }
}
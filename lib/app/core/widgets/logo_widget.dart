import 'package:flutter/material.dart';

class LogoWidget extends StatelessWidget {
  final String imagePath;
  final double size;
  final BoxFit fit;

  const LogoWidget({
    super.key,
    required this.imagePath,
    this.size = 100.0,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      imagePath,
      width: size,
      height: size,
      fit: fit,
    );
  }
}
import 'package:flutter/material.dart';

// Widget for consistent styling
class TextWidget extends StatelessWidget{
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final Color? hoverColor;

  const TextWidget({
    super.key, 
    required this.text, 
    this.style,
    this.textAlign,
    this.hoverColor
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style ?? 
        const TextStyle(
          fontSize: 16, 
          color: Colors.black,
          fontWeight: FontWeight.normal
      ),
    );
  }
}
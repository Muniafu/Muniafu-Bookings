import 'package:flutter/material.dart';

enum ButtonVariant { filled, outlined }

class ButtonWidget extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color color;
  final double? width;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final TextStyle textStyle;
  final bool isFullWidth;
  final ButtonVariant variant;

  const ButtonWidget({
    super.key,
    required this.text,
    required this.onPressed,
    this.color = Colors.indigo,
    this.width,
    this.padding = const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
    this.borderRadius = 12,
    this.textStyle = const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    this.isFullWidth = true,
    this.variant = ButtonVariant.filled,
  });

  @override
  Widget build(BuildContext context) {
    final button = variant == ButtonVariant.filled
        ? ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              padding: padding,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius),
              ),
            ),
            child: Text(text, style: textStyle),
          )
        : OutlinedButton(
            onPressed: onPressed,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: color),
              padding: padding,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius),
              ),
            ),
            child: Text(
              text,
              style: textStyle.copyWith(color: color),
            ),
          );

    return isFullWidth
        ? SizedBox(
            width: width ?? double.infinity,
            child: button,
          )
        : button;
  }
}
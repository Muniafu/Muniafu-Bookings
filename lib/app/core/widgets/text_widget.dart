import 'package:flutter/material.dart';

class TextWidget extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool useThemeDefaults;
  final Color? color;
  final FontWeight? fontWeight;
  final double? fontSize;

  const TextWidget({
    super.key,
    required this.text,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.useThemeDefaults = true,
    this.color,
    this.fontWeight,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final defaultStyle = useThemeDefaults
        ? Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: fontWeight,
              fontSize: fontSize,
            )
        : const TextStyle(
            fontSize: 16,
            color: Colors.black,
            fontWeight: FontWeight.normal,
          ).copyWith(
            color: color,
            fontWeight: fontWeight,
            fontSize: fontSize,
          );

    return Text(
      text,
      style: style?.copyWith(
            color: color,
            fontWeight: fontWeight,
            fontSize: fontSize,
          ) ??
          defaultStyle,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
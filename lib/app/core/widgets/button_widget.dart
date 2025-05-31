import 'package:flutter/material.dart';

enum ButtonVariant { filled, outlined, text }

class ButtonWidget extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final TextStyle? textStyle;
  final bool isFullWidth;
  final ButtonVariant variant;
  final bool isLoading;
  final Widget? icon;
  final MainAxisSize mainAxisSize;
  final double? elevation;
  final bool enableFeedback;

  const ButtonWidget({
    super.key,
    required this.text,
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.width,
    this.height,
    this.padding = const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
    this.borderRadius = 12.0,
    this.textStyle,
    this.isFullWidth = false,
    this.variant = ButtonVariant.filled,
    this.isLoading = false,
    this.icon,
    this.mainAxisSize = MainAxisSize.min,
    this.elevation,
    this.enableFeedback = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDisabled = onPressed == null;
    final effectiveBackgroundColor = backgroundColor ?? theme.colorScheme.primary;
    final effectiveForegroundColor = foregroundColor ??
        (variant == ButtonVariant.filled
            ? theme.colorScheme.onPrimary
            : theme.colorScheme.primary);
    final effectiveBorderColor = borderColor ?? theme.colorScheme.primary;
    final effectiveTextStyle = textStyle ??
        theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: isDisabled ? theme.colorScheme.onSurface.withOpacity(0.38) : 
                 variant == ButtonVariant.filled ? theme.colorScheme.onPrimary : 
                 theme.colorScheme.primary,
        );
    
    final buttonContent = isLoading
        ? SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: variant == ButtonVariant.filled
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.primary,
            ),
          )
        : Row(
            mainAxisSize: mainAxisSize,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                icon!,
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: effectiveTextStyle,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );

    final buttonStyle = ButtonStyle(
      padding: MaterialStateProperty.all(padding),
      shape: MaterialStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          side: variant == ButtonVariant.outlined
              ? BorderSide(color: effectiveBorderColor, width: 1.5)
              : BorderSide.none,
        ),
      ),
      elevation: MaterialStateProperty.all(elevation),
      backgroundColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.disabled)) {
          return variant == ButtonVariant.filled
              ? theme.colorScheme.surface.withOpacity(0.12)
              : Colors.transparent;
        }
        return variant == ButtonVariant.filled
            ? effectiveBackgroundColor
            : Colors.transparent;
      }),
      foregroundColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.disabled)) {
          return theme.colorScheme.onSurface.withOpacity(0.38);
        }
        return variant == ButtonVariant.filled
            ? effectiveForegroundColor
            : effectiveBorderColor;
      }),
      overlayColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.pressed) && enableFeedback) {
          return variant == ButtonVariant.filled
              ? effectiveBackgroundColor.withOpacity(0.2)
              : effectiveBorderColor.withOpacity(0.1);
        }
        return Colors.transparent;
      }),
    );

    Widget button;
    switch (variant) {
      case ButtonVariant.filled:
        button = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle,
          child: buttonContent,
        );
        break;
      case ButtonVariant.outlined:
        button = OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle,
          child: buttonContent,
        );
        break;
      case ButtonVariant.text:
        button = TextButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle,
          child: buttonContent,
        );
        break;
    }

    // Apply size constraints
    if (isFullWidth || width != null || height != null) {
      return SizedBox(
        width: isFullWidth ? double.infinity : width,
        height: height,
        child: button,
      );
    }

    return button;
  }

  // Convenience constructors
  ButtonWidget.filled({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    Color? backgroundColor,
    Color? foregroundColor,
    double? width,
    double? height,
    EdgeInsetsGeometry? padding,
    double borderRadius = 12.0,
    TextStyle? textStyle,
    bool isFullWidth = false,
    bool isLoading = false,
    Widget? icon,
    double? elevation,
  }) : this(
          key: key,
          text: text,
          onPressed: onPressed,
          variant: ButtonVariant.filled,
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          width: width,
          height: height,
          padding: padding ?? const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          borderRadius: borderRadius,
          textStyle: textStyle,
          isFullWidth: isFullWidth,
          isLoading: isLoading,
          icon: icon,
          elevation: elevation,
        );

  ButtonWidget.outlined({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    Color? borderColor,
    Color? foregroundColor,
    double? width,
    double? height,
    EdgeInsetsGeometry? padding,
    double borderRadius = 12.0,
    TextStyle? textStyle,
    bool isFullWidth = false,
    bool isLoading = false,
    Widget? icon,
  }) : this(
          key: key,
          text: text,
          onPressed: onPressed,
          variant: ButtonVariant.outlined,
          borderColor: borderColor,
          foregroundColor: foregroundColor,
          width: width,
          height: height,
          padding: padding ?? const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          borderRadius: borderRadius,
          textStyle: textStyle,
          isFullWidth: isFullWidth,
          isLoading: isLoading,
          icon: icon,
        );

  ButtonWidget.text({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    Color? foregroundColor,
    double? width,
    double? height,
    EdgeInsetsGeometry? padding,
    TextStyle? textStyle,
    bool isFullWidth = false,
    bool isLoading = false,
    Widget? icon,
  }) : this(
          key: key,
          text: text,
          onPressed: onPressed,
          variant: ButtonVariant.text,
          foregroundColor: foregroundColor,
          width: width,
          height: height,
          padding: padding ?? const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          textStyle: textStyle,
          isFullWidth: isFullWidth,
          isLoading: isLoading,
          icon: icon,
        );
}
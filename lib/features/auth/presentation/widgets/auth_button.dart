import 'package:flutter/material.dart';

class AuthButton extends StatelessWidget {
  const AuthButton({
    required this.onPressed,
    required this.text,
    this.isLoading = false, // Добавили
    this.width,
    super.key,
  });

  final String text;
  final VoidCallback? onPressed;
  final double? width;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: 48, // Чуть выше для удобства нажатия
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: isLoading
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
            : Text(text),
      ),
    );
  }
}
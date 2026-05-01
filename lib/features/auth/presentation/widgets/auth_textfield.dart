import 'package:flutter/material.dart';

class AuthTextField extends StatefulWidget {
  const AuthTextField({
    required this.controller,
    this.onChanged, // Сделаем необязательным, чтобы не ругался
    this.keyboardType,
    this.obscureText,
    this.child,
    this.label,
    this.hint,
    this.isPassword = false,
    this.showErrors = false,
    this.validators = const [],
    this.maxLength = 50,
    this.errorText,
    this.enabled = true, // ДОБАВИЛИ: для блокировки при загрузке
    super.key,
  });

  final TextEditingController controller;
  final String? label;
  final String? hint;
  final String? errorText;
  final bool? obscureText;
  final TextInputType? keyboardType;
  final bool isPassword;
  final ValueChanged<String>? onChanged; // Сделали nullable
  final bool showErrors;
  // Исправили тип: теперь принимает String? и возвращает String?
  final List<String? Function(String?)> validators;
  final Widget? child;
  final int? maxLength;
  final bool enabled; // Поле активности

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  String? _error() {
    // Если Firebase вернул конкретную ошибку (errorText), показываем её в приоритете
    if (widget.errorText != null) return widget.errorText;

    if (!widget.showErrors || _focusNode.hasFocus) {
      return null;
    }

    for (final validator in widget.validators) {
      final check = validator(widget.controller.text);
      if (check != null) return check;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (newFocus) => setState(() {}),
      child: TextFormField(
        enabled: widget.enabled, // Применяем состояние активности
        obscureText: widget.obscureText ?? false,
        controller: widget.controller,
        focusNode: _focusNode,
        maxLength: widget.maxLength,
        keyboardType: widget.keyboardType,
        onChanged: (value) {
          widget.onChanged?.call(value); // Безопасный вызов
          setState(() {});
        },
        decoration: InputDecoration(
          suffixIcon: widget.child,
          counter: const SizedBox(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          isDense: true,
          focusedBorder: _getFocusedBorder(),
          enabledBorder: _getBorder(_error() != null),
          errorBorder: _getBorder(true),
          focusedErrorBorder: _getBorder(true),
          errorText: _error(),
          labelText: widget.label, // Используем стандартный labelText
          hintText: _focusNode.hasFocus ? '' : widget.hint,
          hintStyle: const TextStyle(color: Colors.grey),
          fillColor: widget.enabled ? Colors.white : Colors.grey.shade100, // UX
          filled: true,
        ),
      ),
    );
  }

  InputBorder _getBorder(bool isError) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(isError ? 10 : 20),
      borderSide: BorderSide(
        color: isError ? Colors.red : (widget.controller.text.isNotEmpty ? Colors.blueAccent : Colors.blueGrey),
        width: 2,
      ),
    );
  }

  InputBorder _getFocusedBorder() => OutlineInputBorder(
    borderRadius: BorderRadius.circular(16),
    borderSide: const BorderSide(color: Colors.blue, width: 2),
  );
}
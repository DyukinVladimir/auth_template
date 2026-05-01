import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/exceptions/auth_exceptions.dart';
import '../../../../core/validators/auth_validator.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/auth_textfield.dart';

enum AuthType { login, register }

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _passwordHidden = true;
  bool _confirmPasswordHidden = true;
  bool _showErrors = false;

  AuthType _authType = AuthType.login;

  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _toggleMode() {
    setState(() {
      _authType = _authType == AuthType.login ? AuthType.register : AuthType.login;
      _formKey.currentState?.reset();
      _showErrors = false;
      _emailError = null;
      _passwordError = null;
      _emailController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();
    });
  }

  void _submit() {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _showErrors = true);

    if (!_formKey.currentState!.validate()) return;

    if (_authType == AuthType.login) {
      context.read<AuthBloc>().add(AuthBlocEvent.signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
      ));
    } else {
      // Просто передаем всё в Блок
      context.read<AuthBloc>().add(AuthBlocEvent.signUpWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
      ));
    }
  }

  void _handleFailure(AuthException ex) {
    setState(() {
      switch (ex.type) {
        case AuthErrorType.invalidEmail:
        case AuthErrorType.userNotFound:
        case AuthErrorType.emailAlreadyInUse:
          _emailError = ex.message;
          break;
        case AuthErrorType.wrongPassword:
        case AuthErrorType.weakPassword:
          _passwordError = ex.message;
          break;
        default:
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(ex.message), backgroundColor: Colors.red),
          );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final isLoading = authState.maybeWhen(loading: () => true, orElse: () => false);

    return BlocListener<AuthBloc, AuthBlocState>(
      listener: (context, state) {
        state.whenOrNull(
          failure: (ex) => _handleFailure(ex),
        );
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(_authType == AuthType.login ? 'Вход' : 'Регистрация'),
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Form(
                  key: _formKey,
                  autovalidateMode: _showErrors
                      ? AutovalidateMode.always
                      : AutovalidateMode.disabled,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AuthTextField(
                        controller: _emailController,
                        // Исправлено: явная передача val
                        validators: [(val) => AuthValidators.email(val)],
                        label: 'Email',
                        keyboardType: TextInputType.emailAddress,
                        showErrors: _showErrors,
                        errorText: _emailError,
                        enabled: !isLoading,
                        onChanged: (_) => setState(() => _emailError = null),
                      ),
                      const SizedBox(height: 16),
                      AuthTextField(
                        controller: _passwordController,
                        // Исправлено: явная передача val
                        validators: [(val) => AuthValidators.password(val)],
                        label: 'Пароль',
                        showErrors: _showErrors,
                        errorText: _passwordError,
                        obscureText: _passwordHidden,
                        enabled: !isLoading,
                        onChanged: (_) => setState(() => _passwordError = null),
                        child: IconButton(
                          icon: Icon(_passwordHidden
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined),
                          onPressed: () =>
                              setState(() => _passwordHidden = !_passwordHidden),
                        ),
                      ),
                      if (_authType == AuthType.register) ...[
                        const SizedBox(height: 16),
                        AuthTextField(
                          controller: _confirmPasswordController,
                          validators: [
                            // Добавляем скобки () в конце, чтобы вызвать валидатор!
                                (val) => AuthValidators.confirmPassword(_passwordController.text)(val),
                          ],
                          label: 'Подтвердите пароль',
                          showErrors: _showErrors,
                          obscureText: _confirmPasswordHidden,
                          enabled: !isLoading,
                          onChanged: (_) => setState(() {}),
                          child: IconButton(
                            icon: Icon(_confirmPasswordHidden
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined),
                            onPressed: () => setState(() => _confirmPasswordHidden = !_confirmPasswordHidden),
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                        ),
                        child: isLoading
                            ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                            : Text(_authType == AuthType.login
                            ? 'Войти'
                            : 'Создать аккаунт'),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: isLoading ? null : _toggleMode,
                        child: Text(_authType == AuthType.login
                            ? 'Еще нет аккаунта? Зарегистрируйтесь'
                            : 'Уже есть аккаунт? Войдите'),
                      ),
                      if (_authType == AuthType.login)
                        Align(
                          child: TextButton(
                            onPressed: () {
                              final email = _emailController.text.trim();
                              if (email.isEmpty) return;

                              context.read<AuthBloc>().add(
                                AuthBlocEvent.sendPasswordResetEmail(
                                  email: email,
                                  onSuccess: () {
                                    // Этот код выполнится ТОЛЬКО после успешной отправки письма
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Инструкции отправлены на почту!'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                            child: const Text('Забыли пароль?'),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
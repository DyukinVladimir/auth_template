import 'package:firebase_auth/firebase_auth.dart';

enum AuthErrorType {
  invalidEmail,
  emailAlreadyInUse, // Добавили
  userNotFound,
  weakPassword,
  wrongPassword,
  requiresRecentLogin, // Добавили для удаления аккаунта
  network,
  unknown,
}

class AuthException implements Exception {
  final String message;
  final AuthErrorType type;

  const AuthException(this.message, {this.type = AuthErrorType.unknown});

  factory AuthException.fromFirebase(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return const AuthException(
          'Этот email уже занят',
          type: AuthErrorType.emailAlreadyInUse, // Исправили тип
        );
      case 'invalid-email':
        return const AuthException(
          'Некорректный email',
          type: AuthErrorType.invalidEmail,
        );
      case 'user-not-found':
      case 'user-not-verified': // Можно объединить для безопасности
        return const AuthException(
          'Пользователь не найден',
          type: AuthErrorType.userNotFound,
        );
      case 'wrong-password':
        return const AuthException(
          'Неверный пароль',
          type: AuthErrorType.wrongPassword,
        );
      case 'requires-recent-login':
        return const AuthException(
          'Нужно перезайти в приложение для выполнения этого действия',
          type: AuthErrorType.requiresRecentLogin,
        );
    // ... остальные без изменений
      default:
        return AuthException(
          'Ошибка: ${e.message}', // Прокидываем оригинальное сообщение для дебага
          type: AuthErrorType.unknown,
        );
    }
  }
}
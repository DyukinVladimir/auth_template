import 'package:firebase_auth/firebase_auth.dart';

enum AuthErrorType {
  invalidEmail,
  emailAlreadyInUse,
  userNotFound,
  weakPassword,
  wrongPassword,
  requiresRecentLogin,
  network,
  invalidCredential,       // Неверный токен/учетные данные (часто заменяет wrong-password в новых версиях)
  userDisabled,            // Аккаунт заблокирован администратором
  operationNotAllowed,     // Этот метод входа (например, по паролю) отключен в консоли Firebase
  tooManyRequests,         // Спам/слишком много попыток (замораживает вход)
  accountExistsWithDifferentCredential, // Попытка войти через Google с почтой, которая уже зарегистрирована через Email/Password
  credentialAlreadyInUse,  // При линковке аккаунтов: соцсеть уже привязана к другому пользователю
  expiredActionCode,       // Ссылка для сброса пароля/верификации устарела
  invalidActionCode,       // Ссылка для сброса пароля повреждена или уже использована
  userTokenExpired,        // Сессия пользователя устарела (нужен перезапуск)
  operationCancelled,      // Пользователь закрыл окно входа (например, окно выбора Google-аккаунта)
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
          'Этот email уже занят другим аккаунтом.',
          type: AuthErrorType.emailAlreadyInUse,
        );
      case 'invalid-email':
        return const AuthException(
          'Некорректный формат email.',
          type: AuthErrorType.invalidEmail,
        );
      case 'user-not-found':
        return const AuthException(
          'Пользователь с таким email не найден.',
          type: AuthErrorType.userNotFound,
        );
      case 'wrong-password':
        return const AuthException(
          'Неверный пароль.',
          type: AuthErrorType.wrongPassword,
        );
      case 'weak-password':
        return const AuthException(
          'Слишком слабый пароль. Используйте минимум 6 символов.',
          type: AuthErrorType.weakPassword,
        );
      case 'requires-recent-login':
        return const AuthException(
          'Это действие требует повторной авторизации. Пожалуйста, перезайдите в аккаунт.',
          type: AuthErrorType.requiresRecentLogin,
        );

      case 'invalid-credential':
        return const AuthException(
          'Неверный email или пароль.',
          type: AuthErrorType.invalidCredential,
        );

      case 'user-disabled':
        return const AuthException(
          'Ваш аккаунт был заблокирован или отключен администратором.',
          type: AuthErrorType.userDisabled,
        );

      case 'operation-not-allowed':
        return const AuthException(
          'Этот способ авторизации сейчас недоступен.',
          type: AuthErrorType.operationNotAllowed,
        );

      case 'too-many-requests':
        return const AuthException(
          'Слишком много неудачных попыток. Доступ временно заблокирован. Попробуйте позже.',
          type: AuthErrorType.tooManyRequests,
        );

      case 'account-exists-with-different-credential':
        return const AuthException(
          'Этот email уже зарегистрирован с использованием другого способа входа (например, через Google).',
          type: AuthErrorType.accountExistsWithDifferentCredential,
        );

      case 'credential-already-in-use':
        return const AuthException(
          'Этот социальный аккаунт уже привязан к другому пользователю.',
          type: AuthErrorType.credentialAlreadyInUse,
        );

      case 'expired-action-code':
        return const AuthException(
          'Срок действия ссылки (для сброса пароля или верификации) истек.',
          type: AuthErrorType.expiredActionCode,
        );

      case 'invalid-action-code':
        return const AuthException(
          'Неверная или уже использованная ссылка.',
          type: AuthErrorType.invalidActionCode,
        );

      case 'user-token-expired':
        return const AuthException(
          'Ваша сессия устарела. Пожалуйста, авторизуйтесь снова.',
          type: AuthErrorType.userTokenExpired,
        );

      case 'network-request-failed':
        return const AuthException(
          'Ошибка сети. Проверьте подключение к интернету.',
          type: AuthErrorType.network,
        );

      default:
        if (e.code.contains('cancel') || e.message?.contains('canceled') == true) {
          return const AuthException(
            'Операция отменена.',
            type: AuthErrorType.operationCancelled,
          );
        }

        return AuthException(
          'Произошла непредвиденная ошибка: ${e.message ?? e.code}',
          type: AuthErrorType.unknown,
        );
    }
  }
}
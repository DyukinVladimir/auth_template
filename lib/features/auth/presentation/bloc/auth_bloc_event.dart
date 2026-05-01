part of 'auth_bloc.dart';

@freezed
class AuthBlocEvent with _$AuthBlocEvent {
  // Вход
  const factory AuthBlocEvent.signInWithEmail(
      String email,
      String password,
      ) = _SignInWithEmail;

  // Регистрация
  const factory AuthBlocEvent.signUpWithEmail({
    required String email,
    required String password,
    required String confirmPassword,
  }) = _SignUpWithEmail;

  // Выход
  const factory AuthBlocEvent.signOut() = _SignOut;

  // Удаление аккаунта (теперь с обязательным паролем для re-authentication)
  const factory AuthBlocEvent.deleteAccount({
    required String password,
  }) = _DeleteAccount;

  // Сброс пароля (отправка ссылки на почту)
  const factory AuthBlocEvent.sendPasswordResetEmail({
    required String email,
    VoidCallback? onSuccess, // Добавляем колбэк
  }) = _SendPasswordResetEmail;

  // Отправка письма для подтверждения почты
  const factory AuthBlocEvent.sendEmailVerification() = _SendEmailVerification;

  // Обновление профиля (используем также для reload состояния)
  const factory AuthBlocEvent.updateProfile({
    String? displayName,
    String? photoUrl,
  }) = _UpdateProfile;
}

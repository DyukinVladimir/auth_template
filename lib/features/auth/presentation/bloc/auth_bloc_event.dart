part of 'auth_bloc.dart';

@freezed
class AuthBlocEvent with _$AuthBlocEvent {
  const factory AuthBlocEvent.signInWithEmail(
      String email,
      String password,
      ) = _SignInWithEmail;

  const factory AuthBlocEvent.signUpWithEmail({
    required String email,
    required String password,
    required String confirmPassword,
  }) = _SignUpWithEmail;

  const factory AuthBlocEvent.signOut() = _SignOut;

  const factory AuthBlocEvent.deleteAccount({
    required String password,
  }) = _DeleteAccount;

  const factory AuthBlocEvent.sendPasswordResetEmail({
    required String email,
    VoidCallback? onSuccess, // Добавляем колбэк
  }) = _SendPasswordResetEmail;

  const factory AuthBlocEvent.sendEmailVerification() = _SendEmailVerification;

  const factory AuthBlocEvent.updateProfile({
    String? displayName,
    String? photoUrl,
  }) = _UpdateProfile;
}

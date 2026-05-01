import 'package:auth_template/core/exceptions/auth_exceptions.dart';
import 'package:auth_template/features/auth/data/datasources/firebase_auth_datasource_abstract.dart';
import 'package:auth_template/features/auth/data/model/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';

class FirebaseAuthRemoteDataSourceImpl implements FirebaseAuthRemoteDataSourceAbst {
  FirebaseAuthRemoteDataSourceImpl(this._auth, this._logger);
  final FirebaseAuth _auth;
  final Logger _logger;

  @override
  Stream<UserModel?> authStateChanges() {
    return _auth.userChanges().map(
          (user) => user == null ? null : UserModel.fromFirebase(user),
    );
  }

  @override
  Future<void> reauthenticate(String password) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.email == null) throw const AuthException('Сессия истекла');

      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebase(e);
    } catch (e) {
      throw AuthException('Ошибка проверки личности: ${e.toString()}');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      return user == null ? null : UserModel.fromFirebase(user);
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebase(e);
    } catch (e) {
      throw AuthException('Системная ошибка: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> signUpWithEmail(String email, String password) async {
    try {
      _logger.i('📝 DataSource: Creating account for $email');

      // Добавляем .timeout()
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      ).timeout(const Duration(seconds: 15), onTimeout: () {
        throw const AuthException('Превышено время ожидания. Проверьте интернет или VPN.');
      });

      _logger.i('🎉 DataSource: Account created');
      return UserModel.fromFirebase(credential.user!);
    } on FirebaseAuthException catch (e, stackTrace) {
      _logger.e('🛑 Firebase Error', error: e, stackTrace: stackTrace);
      throw AuthException.fromFirebase(e);
    } catch (e, stackTrace) {
      _logger.f('💥 Unknown Error', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<UserModel> signInWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return UserModel.fromFirebase(credential.user!);
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebase(e);
    } catch (e) {
      throw AuthException('Ошибка входа: ${e.toString()}');
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebase(e);
    } catch (e) {
      throw AuthException('Ошибка отправки письма: ${e.toString()}');
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebase(e);
    } catch (e) {
      throw AuthException('Ошибка сброса пароля: ${e.toString()}');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw AuthException('Ошибка выхода: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteAccount(String password) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw const AuthException('Пользователь не найден');

      // 1. Сначала переподтверждаем личность
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);

      // 2. Только после успеха удаляем
      await user.delete();
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebase(e);
    } catch (e) {
      throw AuthException('Ошибка при удалении: ${e.toString()}');
    }
  }

  @override
  Future<void> reloadUser() async {
    try {
      await _auth.currentUser?.reload();
    } catch (e) {
      throw AuthException('Ошибка обновления: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> updateProfile({String? displayName, String? photoUrl}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw const AuthException('Не авторизован');

      if (displayName != null) await user.updateDisplayName(displayName);
      if (photoUrl != null) await user.updatePhotoURL(photoUrl);

      await user.reload();
      return UserModel.fromFirebase(_auth.currentUser!);
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebase(e);
    } catch (e) {
      throw AuthException('Ошибка профиля: ${e.toString()}');
    }
  }
}
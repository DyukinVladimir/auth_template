
import '../model/user_model.dart';

abstract class FirebaseAuthRemoteDataSourceAbst {
  Stream<UserModel?> authStateChanges();

  Future<UserModel?> getCurrentUser();

  Future<UserModel> signUpWithEmail(String email, String password);

  Future<UserModel> signInWithEmail(String email, String password);

  Future<void> sendEmailVerification();

  Future<void> sendPasswordResetEmail(String email);

  Future<void> signOut();

  Future<void> deleteAccount(String password);

  Future<void> reloadUser();

  Future<void> reauthenticate(String password);

  Future<UserModel> updateProfile({String? displayName, String? photoUrl});
}

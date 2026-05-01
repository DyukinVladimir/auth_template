import 'package:auth_template/core/exceptions/auth_exceptions.dart';
import 'package:auth_template/features/auth/domain/repo/auth_repo_abstract.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_bloc_event.dart';
part 'auth_bloc_state.dart';
part 'auth_bloc.freezed.dart';


class AuthBloc extends Bloc<AuthBlocEvent, AuthBlocState> {
  final AuthRepo _repo;

  AuthBloc(this._repo) : super(const AuthBlocState.initial()) {
    on<AuthBlocEvent>(
          (event, emit) async {
        await event.map(
          signInWithEmail: (e) => _handleAuthTask(emit,
                () => _repo.signInWithEmail(e.email, e.password),
          ),

          signUpWithEmail: (e) => _handleAuthTask(emit, () async {
            if (e.password != e.confirmPassword) {
              throw AuthException('Пароли не совпадают', type: AuthErrorType.wrongPassword);
            }
            return _repo.signUpWithEmail(e.email, e.password);
          }),

          signOut: (e) => _handleAuthTask(emit,
                () => _repo.signOut(),
          ),

          deleteAccount: (e) => _handleAuthTask(emit, () async {
            if (e.password.isEmpty) {
              throw AuthException('Введите пароль для удаления', type: AuthErrorType.wrongPassword);
            }
            return _repo.deleteAccount(e.password);
          }),

          sendPasswordResetEmail: (e) => _handleAuthTask(emit,
                () => _repo.sendPasswordResetEmail(e.email),
          ),

          sendEmailVerification: (e) => _handleAuthTask(emit,
                () => _repo.sendEmailVerification(),
          ),

          updateProfile: (e) => _handleAuthTask(emit,
                () => _repo.updateProfile(
              displayName: e.displayName,
              photoUrl: e.photoUrl,
            ),
          ),
        );
      },
      transformer: droppable(), // Защита от спама кнопками
    );
  }

  Future<void> _handleAuthTask(
      Emitter<AuthBlocState> emit,
      Future<dynamic> Function() task,
      ) async {
    emit(const AuthBlocState.loading());
    try {
      await task();
      emit(const AuthBlocState.success());
    } on AuthException catch (ex) {
      emit(AuthBlocState.failure(ex));
    } catch (e) {
      emit(AuthBlocState.failure(AuthException(e.toString())));
    }
  }
}
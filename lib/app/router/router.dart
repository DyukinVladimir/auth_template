import 'dart:async';
import 'package:auth_template/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:auth_template/features/auth/presentation/pages/login.dart';
import 'package:auth_template/features/auth/presentation/pages/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

GoRouter createRouter(AuthCubit authCubit) {
  return GoRouter(
    initialLocation: '/profile', // Меняем стартовую локацию

    refreshListenable: GoRouterRefreshStream(authCubit.stream),

    redirect: (context, state) {
      final authState = authCubit.state;

      final isSplash = state.matchedLocation == '/splash';
      final isAuthPage = state.matchedLocation == '/login';

      return authState.when(
        initial: () => isSplash ? null : '/splash',

        unauthenticated: () {
          if (isAuthPage) return null;
          return '/login';
        },

        authenticated: (_) {
          // Если авторизован и пытается зайти на splash или login — кидаем в профиль
          if (isSplash || isAuthPage) {
            return '/profile';
          }
          return null;
        },
      );
    },

    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) =>
        const Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      // Теперь профиль — это корневой экран после входа
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfilePage(),
      ),
    ],
  );
}
import 'package:auth_template/features/auth/domain/entity/user_entity.dart';
import 'package:auth_template/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:auth_template/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

// Добавляем WidgetsBindingObserver для отслеживания состояния приложения
class _ProfilePageState extends State<ProfilePage> with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // Начинаем слушать
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Обязательно удаляем
    super.dispose();
  }

  // Магия происходит здесь
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Если пользователь вернулся в приложение (resumed)
    if (state == AppLifecycleState.resumed) {
      // Вызываем обновление профиля, чтобы проверить статус подтверждения Email
      context.read<AuthBloc>().add(const AuthBlocEvent.updateProfile());
    }
  }

  void _showDeleteDialog(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        // Оборачиваем в BlocBuilder, чтобы кнопка в диалоге знала о загрузке
        return BlocBuilder<AuthBloc, AuthBlocState>(
          builder: (context, state) {
            final isLoading = state.maybeWhen(loading: () => true, orElse: () => false);

            return AlertDialog(
              title: const Text('Удаление аккаунта'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Для подтверждения введите текущий пароль:'),
                  const SizedBox(height: 12),
                  TextField(
                    controller: controller,
                    obscureText: true,
                    enabled: !isLoading,
                    decoration: const InputDecoration(
                      labelText: 'Пароль',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.pop(dialogContext),
                  child: const Text('Отмена'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: isLoading ? null : () {
                    final password = controller.text.trim();
                    if (password.isNotEmpty) {
                      context.read<AuthBloc>().add(AuthBlocEvent.deleteAccount(password: password));
                      // Диалог закроется сам через BlocListener ниже при успехе
                    }
                  },
                  child: isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Удалить', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Выбираем только данные пользователя для перерисовки
    final user = context.select<AuthCubit, UserEntity?>(
          (cubit) => cubit.state.maybeWhen(
        authenticated: (user) => user,
        orElse: () => null,
      ),
    );

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<AuthBloc>().add(const AuthBlocEvent.updateProfile()),
          ),
        ],
      ),
      body: BlocListener<AuthBloc, AuthBlocState>(
        listener: (context, state) {
          state.whenOrNull(
            failure: (ex) => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(ex.message), backgroundColor: Colors.red),
            ),
            success: () {
              // Если диалог был открыт (при удалении), закрываем его
              if (Navigator.canPop(context)) Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Успешно выполнено')),
              );
            },
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(user.displayName ?? 'Пользователь'),
                  subtitle: Text(user.email ?? ''),
                  trailing: user.isEmailVerified
                      ? const Icon(Icons.verified, color: Colors.green)
                      : const Icon(Icons.warning_amber, color: Colors.orange),
                ),
              ),
              const SizedBox(height: 24),

              if (!user.isEmailVerified) ...[
                _ProfileButton(
                  icon: Icons.mark_email_read,
                  label: 'Отправить письмо подтверждения',
                  color: Colors.blue,
                  onPressed: () => context.read<AuthBloc>().add(const AuthBlocEvent.sendEmailVerification()),
                ),
                const SizedBox(height: 12),
              ],

              _ProfileButton(
                icon: Icons.lock_reset,
                label: 'Сбросить пароль',
                onPressed: () {
                  if (user.email != null) {
                    context.read<AuthBloc>().add(AuthBlocEvent.sendPasswordResetEmail(user.email!));
                  }
                },
              ),
              const Spacer(),
              _ProfileButton(
                icon: Icons.logout,
                label: 'Выйти',
                color: Colors.grey[800],
                onPressed: () => context.read<AuthBloc>().add(const AuthBlocEvent.signOut()),
              ),
              const SizedBox(height: 12),
              _ProfileButton(
                icon: Icons.delete_forever,
                label: 'Удалить аккаунт',
                color: Colors.red,
                isOutlined: true,
                onPressed: () => _showDeleteDialog(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Виджет _ProfileButton оставляем без изменений

// Вспомогательный виджет для кнопок, чтобы код был чище
class _ProfileButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color? color;
  final bool isOutlined;

  const _ProfileButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.color,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = ElevatedButton.styleFrom(
      foregroundColor: color,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );

    return SizedBox(
      width: double.infinity,
      child: isOutlined
          ? OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color ?? Colors.grey),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      )
          : ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: style,
      ),
    );
  }
}
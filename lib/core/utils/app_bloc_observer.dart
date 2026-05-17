import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import '../../core/di/init_dependencies.dart';

class AppBlocObserver extends BlocObserver {
  final Logger _logger = getIt<Logger>();

  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    _logger.i('BLOC EVENT: ${bloc.runtimeType} -> $event');
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    _logger.d('BLOC CHANGE in ${bloc.runtimeType}: \nFROM: ${change.currentState} \nTO: ${change.nextState}');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    _logger.e('BLOC ERROR: ${bloc.runtimeType}', error: error, stackTrace: stackTrace);
    super.onError(bloc, error, stackTrace);
  }
}
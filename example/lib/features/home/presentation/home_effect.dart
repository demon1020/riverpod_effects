import 'package:riverpod_effects/riverpod_effects.dart';

sealed class HomeEffect extends UiEffect {
  const HomeEffect();
}

class ShowHomeSnackBar extends HomeEffect {
  final String message;
  const ShowHomeSnackBar(this.message);
}

class LogoutRequested extends HomeEffect {
  const LogoutRequested();
}

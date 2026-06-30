import 'package:riverpod_effects/riverpod_effects.dart';

sealed class LoginEffect extends UiEffect {
  const LoginEffect();
}

class NavigateHome extends LoginEffect {
  const NavigateHome();
}

class ShowSnackBar extends LoginEffect {
  final String message;
  const ShowSnackBar(this.message);
}

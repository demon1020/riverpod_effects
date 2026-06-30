import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod_effects/riverpod_effects.dart';

import 'login_effect.dart';
import 'login_state.dart';

part 'login_view_model.g.dart';

@riverpod
class LoginViewModel extends _$LoginViewModel
    with EffectMixin<LoginEffect> {
  @override
  LoginState build() {
    initEffects(ref);
    return const LoginState();
  }

  Future<void> login() async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(seconds: 1));
    state = state.copyWith(isLoading: false);

    final success =
        state.username == 'admin' && state.password == 'admin';

    if (success) {
      emitEffect(const ShowSnackBar('Login Successful'));
      emitEffect(const NavigateHome());
    } else {
      emitEffect(const ShowSnackBar('Invalid credentials'));
    }
  }

  void setUsername(String value) => state = state.copyWith(username: value);

  void setPassword(String value) => state = state.copyWith(password: value);
}

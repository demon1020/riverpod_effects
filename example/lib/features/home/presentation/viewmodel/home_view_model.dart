import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod_effects/riverpod_effects.dart';

import '../state/home_effect.dart';
import '../state/home_state.dart';

part 'home_view_model.g.dart';

@riverpod
class HomeViewModel extends _$HomeViewModel
    with EffectMixin<HomeEffect, HomeState> {
  @override
  Future<HomeState> build() async {
    return await _homeState();
  }

  Future<HomeState> _homeState() async {
    await Future.delayed(const Duration(seconds: 1));
    return const HomeState(
      homeState: AsyncValue.data('Welcome to the Home Page!'),
    );
  }

  Future<void> loadHome() async {
    state = const AsyncValue.loading();
    try {
      await Future.delayed(const Duration(seconds: 1));
      state = AsyncValue.data(
        const HomeState(
          homeState: AsyncValue.data('Welcome to the Home Page!'),
        ),
      );
      emitEffect(const ShowHomeSnackBar('Home loaded successfully'));
    } catch (e, st) {
      state = AsyncValue.data(HomeState(homeState: AsyncValue.error(e, st)));
    }
  }

  void logout() {
    emitEffect(const ShowHomeSnackBar('Logged out successfully'));
    emitEffect(const LogoutRequested());
  }
}

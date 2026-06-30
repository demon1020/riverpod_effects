import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_effects/riverpod_effects.dart';

import '../state/home_effect.dart';
import '../viewmodel/home_view_model.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeViewModelProvider);
    final notifier = ref.read(homeViewModelProvider.notifier);

    return EffectConsumer<HomeEffect>(
      stream: notifier.effects,
      listener: (context, effect) {
        switch (effect) {
          case LogoutRequested():
            context.go('/login');
          case ShowHomeSnackBar(message: final msg):
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(msg)),
            );
        }
      },
      builder: (context) => Scaffold(
        appBar: AppBar(title: const Text('Home')),
        body: state.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Error: $error',
                  style: const TextStyle(fontSize: 18, color: Colors.red),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => notifier.loadHome(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
          data: (homeState) => Center(
            child: homeState.homeState.when(
              loading: () => const CircularProgressIndicator(),
              error: (error, _) => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: $error',
                    style: const TextStyle(fontSize: 18, color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => notifier.loadHome(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
              data: (value) => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    value,
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: notifier.logout,
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () => notifier.loadHome(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

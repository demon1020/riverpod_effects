import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'features/home/presentation/view/home_page.dart';
import 'features/login/presentation/view/login_page.dart';

final goRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    GoRoute(path: '/home', builder: (context, state) => const HomePage()),
  ],
);

void main() => runApp(const ProviderScope(child: RiverpodEffectsApp()));

class RiverpodEffectsApp extends StatelessWidget {
  const RiverpodEffectsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Riverpod Effects',
      routerConfig: goRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}

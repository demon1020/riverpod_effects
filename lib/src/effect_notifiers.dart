import 'dart:async';

import 'package:riverpod/riverpod.dart';

import 'effect.dart';
import 'effect_mixin.dart';

/// A [Notifier] with built-in effect support via [EffectMixin].
///
/// No manual initialization needed.
///
/// ```dart
/// class MyNotifier extends EffectsNotifier<MyEffect, MyState> {
///   @override
///   MyState build() => const MyState();
///
///   void save() => emitEffect(const Saved());
/// }
///
/// final myProvider = NotifierProvider<MyNotifier, MyState>(MyNotifier.new);
/// ```
abstract class EffectsNotifier<E extends UiEffect, T> extends Notifier<T>
    with EffectMixin<E, T> {
  @override
  T build();
}

/// An [AsyncNotifier] with built-in effect support via [EffectMixin].
///
/// No manual initialization needed.
///
/// ```dart
/// class MyNotifier extends AsyncEffectsNotifier<MyEffect, MyState> {
///   @override
///   Future<MyState> build() async => await fetchMyState();
///
///   void refresh() => emitEffect(const Refreshed());
/// }
///
/// final myProvider = AsyncNotifierProvider<MyNotifier, MyState>(MyNotifier.new);
/// ```
abstract class AsyncEffectsNotifier<E extends UiEffect, T>
    extends AsyncNotifier<T>
    with EffectMixin<E, T> {
  @override
  FutureOr<T> build();
}

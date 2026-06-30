import 'dart:async';

import 'package:riverpod/riverpod.dart';

import 'effect.dart';
import 'effect_emitter.dart';
import 'effect_notifier.dart';

/// A mixin that adds effect-emitting capability to a sync [Notifier].
///
/// The effect stream is **automatically disposed** when the notifier is
/// disposed — no manual initialization needed.
///
/// ## Usage
///
/// ```dart
/// @riverpod
/// class MyViewModel extends _$MyViewModel with EffectMixin<MyEffect, MyState> {
///   @override
///   MyState build() => const MyState();
///
///   void save() => emitEffect(const Saved());
/// }
/// ```
///
/// For [AsyncNotifier] use [AsyncEffectMixin].
mixin EffectMixin<E extends UiEffect, T> on AnyNotifier<T, T>
    implements EffectNotifier<E> {
  final EffectEmitter<E> _emitter = EffectEmitter<E>();

  @override
  void Function(void Function())? runBuild() {
    super.runBuild();
    ref.onDispose(_emitter.dispose);
    return null;
  }

  @override
  Stream<E> get effects => _emitter.stream;

  /// Whether at least one listener is currently subscribed.
  bool get hasListener => _emitter.hasListener;

  /// Emits a one-time effect to all current and future listeners.
  void emitEffect(E effect) => _emitter.emit(effect);

  /// Subscribes to the effect stream from non-widget code.
  StreamSubscription<E> listen(
    void Function(E) onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) =>
      _emitter.listen(
        onData,
        onError: onError,
        onDone: onDone,
        cancelOnError: cancelOnError,
      );
}

/// A mixin that adds effect-emitting capability to an [AsyncNotifier].
///
/// The effect stream is **automatically disposed** when the notifier is
/// disposed — no manual initialization needed.
///
/// ## Usage
///
/// ```dart
/// @riverpod
/// class MyViewModel extends _$MyViewModel
///     with AsyncEffectMixin<MyEffect, MyState> {
///   @override
///   Future<MyState> build() async => await fetchMyState();
///
///   void refresh() => emitEffect(const Refreshed());
/// }
/// ```
mixin AsyncEffectMixin<E extends UiEffect, T>
    on AnyNotifier<AsyncValue<T>, T>
    implements EffectNotifier<E> {
  final EffectEmitter<E> _emitter = EffectEmitter<E>();

  @override
  void Function(void Function())? runBuild() {
    super.runBuild();
    ref.onDispose(_emitter.dispose);
    return null;
  }

  @override
  Stream<E> get effects => _emitter.stream;

  /// Whether at least one listener is currently subscribed.
  bool get hasListener => _emitter.hasListener;

  /// Emits a one-time effect to all current and future listeners.
  void emitEffect(E effect) => _emitter.emit(effect);

  /// Subscribes to the effect stream from non-widget code.
  StreamSubscription<E> listen(
    void Function(E) onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) =>
      _emitter.listen(
        onData,
        onError: onError,
        onDone: onDone,
        cancelOnError: cancelOnError,
      );
}

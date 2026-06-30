import 'dart:async';

import 'package:riverpod/riverpod.dart';

import 'effect.dart';
import 'effect_emitter.dart';
import 'effect_notifier.dart';

/// A mixin that adds effect-emitting capability to a Riverpod notifier.
///
/// ```dart
/// @riverpod
/// class MyViewModel extends _$MyViewModel with EffectMixin<MyEffect> {
///   @override
///   int build() {
///     initEffects(ref);
///     return 0;
///   }
///
///   void save() {
///     emitEffect(const ShowSnackBar('Saved!'));
///   }
/// }
/// ```
///
/// Call [initEffects] inside `build()` to register automatic cleanup of
/// the effect stream when the provider is disposed.
mixin EffectMixin<E extends UiEffect> implements EffectNotifier<E> {
  final EffectEmitter<E> _emitter = EffectEmitter<E>();

  /// Initialises the effect lifecycle.
  ///
  /// Registers [disposeEffects] to run when the notifier is disposed.
  /// Call this once inside your `build()` method:
  /// ```dart
  /// @override
  /// int build() {
  ///   initEffects(ref);
  ///   return 0;
  /// }
  /// ```
  void initEffects(Ref ref) {
    ref.onDispose(disposeEffects);
  }

  @override
  Stream<E> get effects => _emitter.stream;

  /// Whether at least one listener is currently subscribed.
  ///
  /// Useful for skipping expensive work when no UI is listening:
  /// ```dart
  /// if (hasListener) emitEffect(ExpensiveEffect());
  /// ```
  bool get hasListener => _emitter.hasListener;

  /// Emits a one-time effect to all current and future listeners.
  void emitEffect(E effect) => _emitter.emit(effect);

  /// Subscribes to the effect stream from non-widget code.
  ///
  /// Example:
  /// ```dart
  /// final sub = notifier.listen((effect) {
  ///   // handle effect in a service or another notifier
  /// });
  /// // later: sub.cancel();
  /// ```
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

  /// Disposes the effect emitter.
  ///
  /// Called automatically by [initEffects] on provider disposal. Idempotent.
  void disposeEffects() => _emitter.dispose();
}

import 'dart:async';

import 'package:riverpod/riverpod.dart';

import 'effect.dart';
import 'effect_emitter.dart';
import 'effect_notifier.dart';

/// A mixin that adds effect-emitting capability to a Riverpod [Notifier] or
/// generated `$Notifier` subclass.
///
/// The effect stream is **automatically disposed** when the notifier is
/// disposed — no manual lifecycle wiring is needed.
///
/// ```dart
/// @riverpod
/// class MyViewModel extends _$MyViewModel with EffectMixin<MyEffect, int> {
///   @override
///   int build() => 0;
///
///   void save() {
///     emitEffect(const ShowSnackBar('Saved!'));
///   }
/// }
///
/// // In the UI:
/// EffectConsumer<MyEffect>(
///   stream: notifier.effects,
///   listener: (context, effect) { /* ... */ },
///   builder: (context) => Scaffold(/* ... */),
/// )
/// ```
///
/// The second type parameter `T` is the notifier's state type. For a
/// `Notifier<MyState>`, use `EffectMixin<MyEffect, MyState>`. For an
/// `AsyncNotifier<MyState>`, use `EffectMixin<MyEffect, AsyncValue<MyState>>`.
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

  /// Disposes the effect emitter. Idempotent.
  ///
  /// Called automatically when the notifier is disposed. You should not
  /// need to call this manually.
  void disposeEffects() => _emitter.dispose();
}

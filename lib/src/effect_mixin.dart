import 'dart:async';

import 'package:meta/meta.dart';
import 'package:riverpod/riverpod.dart';

import 'effect.dart';
import 'effect_emitter.dart';
import 'effect_notifier.dart';

/// A mixin that adds effect-emitting capability to any Riverpod notifier
/// (both sync [Notifier] and [AsyncNotifier]).
///
/// The effect stream is **automatically disposed** when the notifier is
/// disposed — no manual initialization needed.
///
/// ## Usage with sync notifier
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
/// ## Usage with async notifier
///
/// ```dart
/// @riverpod
/// class MyViewModel extends _$MyViewModel with EffectMixin<MyEffect, MyState> {
///   @override
///   Future<MyState> build() async => await fetchMyState();
///
///   void save() => emitEffect(const Saved());
/// }
/// ```
mixin EffectMixin<E extends UiEffect, T> implements EffectNotifier<E> {
  EffectEmitter<E>? _emitter;

  /// The [Ref] provided by the Riverpod notifier.
  Ref get ref;

  /// Override to configure the [EffectEmitter], e.g. to enable [replay][EffectEmitter]:
  ///
  /// ```dart
  /// @override
  /// EffectEmitter<MyEffect> createEffectEmitter() =>
  ///     EffectEmitter<MyEffect>(replay: 5);
  /// ```
  @protected
  EffectEmitter<E> createEffectEmitter() => EffectEmitter<E>();

  void _initEmitter() {
    if (_emitter != null) return;
    _emitter = createEffectEmitter();
    try {
      ref.onDispose(_emitter!.dispose);
    } on Object {
      // notifier already disposed — emitter will be GC'd
    }
  }

  @override
  Stream<E> get effects {
    _initEmitter();
    return _emitter!.stream;
  }

  /// Whether at least one listener is currently subscribed.
  bool get hasListener => _emitter?.hasListener ?? false;

  /// Emits a one-time effect to all current and future listeners.
  void emitEffect(E effect) {
    _initEmitter();
    _emitter!.emit(effect);
  }

  /// Subscribes to the effect stream from non-widget code.
  StreamSubscription<E> listen(
    void Function(E) onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    _initEmitter();
    return _emitter!.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError ?? false,
    );
  }
}

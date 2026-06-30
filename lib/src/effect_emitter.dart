import 'dart:async';

import 'effect.dart';

/// A stream-based emitter for one-time [UiEffect]s.
///
/// Effects are delivered in **FIFO** order — the order in which [emit] was
/// called is preserved for every listener.
///
/// By default, listeners only receive effects emitted after they subscribe.
/// Pass [replay] to buffer past effects for late subscribers.
class EffectEmitter<E extends UiEffect> {
  final StreamController<E> _controller = StreamController<E>.broadcast();
  final List<E> _history = [];
  final int _maxReplays;

  /// Creates an emitter.
  ///
  /// When [replay] > 0, each new listener immediately receives the last
  /// [replay] effects that were emitted before it subscribed.
  EffectEmitter({int replay = 0}) : _maxReplays = replay;

  /// Whether the controller has been closed via [dispose].
  bool get isDisposed => _controller.isClosed;

  /// Whether at least one listener is currently subscribed.
  bool get hasListener => _controller.hasListener;

  /// Emits an effect to all current and future listeners.
  ///
  /// Has no effect if the emitter has already been [dispose]d.
  void emit(E effect) {
    if (_controller.isClosed) return;
    if (_maxReplays > 0) {
      _history.add(effect);
      if (_history.length > _maxReplays) _history.removeAt(0);
    }
    _controller.add(effect);
  }

  /// A broadcast stream delivering every emitted effect to each listener.
  ///
  /// When [replay] was specified in the constructor, new listeners first
  /// receive buffered past effects, followed by future ones.
  Stream<E> get stream {
    if (_history.isEmpty) return _controller.stream;
    return Stream<E>.multi((controller) {
      final history = List<E>.of(_history);
      for (final effect in history) {
        controller.add(effect);
      }
      final sub = _controller.stream.listen(
        controller.add,
        onError: controller.addError,
        onDone: controller.close,
        cancelOnError: false,
      );
      controller.onCancel = sub.cancel;
    }, isBroadcast: true);
  }

  /// Closes the emitter. Subsequent [emit] calls are silently ignored.
  void dispose() => _controller.close();

  /// Subscribes to the effect stream from non-widget code.
  ///
  /// Convenience wrapper around [stream.listen] that defaults to
  /// `cancelOnError: false`.
  StreamSubscription<E> listen(
    void Function(E) onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) => stream.listen(
    onData,
    onError: onError,
    onDone: onDone,
    cancelOnError: cancelOnError ?? false,
  );
}

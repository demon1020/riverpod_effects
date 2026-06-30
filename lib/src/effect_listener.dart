import 'dart:async';

import 'package:flutter/widgets.dart';

import 'effect.dart';

/// A stateful widget that subscribes to a [Stream] of [UiEffect]s and
/// invokes [listener] for each emitted effect.
///
/// The subscription is created in [State.initState], updated when [stream]
/// changes, and cancelled in [State.dispose]. Stream errors are reported
/// via [FlutterError.reportError] and do not crash the widget tree.
class EffectListener<E extends UiEffect> extends StatefulWidget {
  /// The stream to listen to.
  final Stream<E> stream;

  /// Called with the current [BuildContext] for each emitted effect.
  final void Function(BuildContext context, E effect) listener;

  /// The widget subtree rendered below this listener.
  final Widget child;

  const EffectListener({
    super.key,
    required this.stream,
    required this.listener,
    required this.child,
  });

  @override
  State<EffectListener<E>> createState() => _EffectListenerState<E>();
}

class _EffectListenerState<E extends UiEffect>
    extends State<EffectListener<E>> {
  StreamSubscription<E>? _subscription;

  @override
  void initState() {
    super.initState();
    _subscribe();
  }

  @override
  void didUpdateWidget(covariant EffectListener<E> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stream != widget.stream) {
      _subscription?.cancel();
      _subscribe();
    }
  }

  void _subscribe() {
    _subscription = widget.stream.listen(
      (effect) {
        if (mounted) {
          widget.listener(context, effect);
        }
      },
      onError: (Object error, StackTrace stackTrace) {
        if (mounted) {
          FlutterError.reportError(
            FlutterErrorDetails(
              exception: error,
              stack: stackTrace,
              context: ErrorDescription('EffectListener stream error'),
            ),
          );
        }
      },
      cancelOnError: false,
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

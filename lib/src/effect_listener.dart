import 'dart:async';

import 'package:flutter/widgets.dart';

import 'effect.dart';

class EffectListener<E extends UiEffect> extends StatefulWidget {
  final Stream<E> stream;
  final void Function(BuildContext context, E effect) listener;
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
    _subscription = widget.stream.listen((effect) {
      if (mounted) {
        widget.listener(context, effect);
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

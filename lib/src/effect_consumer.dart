import 'dart:async';

import 'package:flutter/widgets.dart';

import 'effect.dart';
import 'effect_listener.dart';

class EffectConsumer<E extends UiEffect> extends StatelessWidget {
  final Stream<E> stream;
  final void Function(BuildContext context, E effect) listener;
  final Widget Function(BuildContext context) builder;

  const EffectConsumer({
    super.key,
    required this.stream,
    required this.listener,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return EffectListener<E>(
      stream: stream,
      listener: listener,
      child: Builder(builder: builder),
    );
  }
}

import 'dart:async';

import 'package:flutter/widgets.dart';

import 'effect.dart';
import 'effect_listener.dart';

/// A convenience widget that combines [EffectListener] with a [builder].
///
/// Subscribes to an effect [stream] and invokes [listener] for each emitted
/// effect, while rendering the widget subtree returned by [builder].
///
/// ```dart
/// EffectConsumer<MyEffect>(
///   stream: notifier.effects,
///   listener: (context, effect) {
///     switch (effect) {
///       case NavigateHome(): context.go('/home');
///       case ShowSnackBar(message: final m):
///         ScaffoldMessenger.of(context).showSnackBar(
///           SnackBar(content: Text(m)),
///         );
///     }
///   },
///   builder: (context) => Scaffold(/* ... */),
/// )
/// ```
class EffectConsumer<E extends UiEffect> extends StatelessWidget {
  /// The effect stream to listen to.
  final Stream<E> stream;

  /// Called with the current [BuildContext] for each emitted effect.
  final void Function(BuildContext context, E effect) listener;

  /// Builds the widget subtree rendered below the effect listener.
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

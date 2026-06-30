import 'effect.dart';

/// Abstract contract for notifiers that expose an [effects] stream.
///
/// {@template riverpod_effects.effect_notifier}
/// Implement this interface to declare that a notifier emits one-time effects.
/// {@endtemplate}
///
/// Use [EffectMixin] instead — it implements this interface automatically.
@Deprecated('Use EffectMixin directly instead. EffectNotifier is a legacy '
    'interface that will be removed in a future release.')
abstract class EffectNotifier<E extends UiEffect> {
  /// A broadcast stream of one-time effects emitted by this notifier.
  Stream<E> get effects;
}

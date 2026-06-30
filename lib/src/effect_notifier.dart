import 'effect.dart';

/// Interface for notifiers that expose an [effects] stream.
///
/// Implemented automatically by [EffectMixin].
abstract interface class EffectNotifier<E extends UiEffect> {
  Stream<E> get effects;
}

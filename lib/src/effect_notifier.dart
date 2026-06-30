import 'effect.dart';

abstract class EffectNotifier<E extends UiEffect> {
  Stream<E> get effects;
}

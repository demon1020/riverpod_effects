import 'effect.dart';
import 'effect_emitter.dart';
import 'effect_notifier.dart';

mixin EffectMixin<E extends UiEffect> implements EffectNotifier<E> {
  final EffectEmitter<E> _emitter = EffectEmitter<E>();

  @override
  Stream<E> get effects => _emitter.stream;

  void emitEffect(E effect) => _emitter.emit(effect);

  void disposeEffects() => _emitter.dispose();
}

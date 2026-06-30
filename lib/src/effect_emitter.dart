import 'dart:async';

import 'effect.dart';

class EffectEmitter<E extends UiEffect> {
  final StreamController<E> _controller = StreamController<E>.broadcast();

  void emit(E effect) => _controller.add(effect);

  Stream<E> get stream => _controller.stream;

  void dispose() => _controller.close();
}

import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_effects/riverpod_effects.dart';

class _Effect extends UiEffect {
  const _Effect();
}

class _Effect2 extends _Effect {
  const _Effect2();
}

void main() {
  group('EffectEmitter', () {
    test('emit delivers effect to stream listener', () async {
      final emitter = EffectEmitter<_Effect>();
      final effects = <_Effect>[];
      final sub = emitter.stream.listen(effects.add);

      emitter.emit(const _Effect());
      await Future(() {});
      expect(effects, hasLength(1));

      await sub.cancel();
      emitter.dispose();
    });

    test('effects delivered in FIFO order', () async {
      final emitter = EffectEmitter<_Effect>();
      final effects = <_Effect>[];
      final sub = emitter.stream.listen(effects.add);

      emitter.emit(const _Effect());
      emitter.emit(const _Effect2());
      await Future(() {});
      expect(effects, hasLength(2));
      expect(effects[0], isA<_Effect>());
      expect(effects[1], isA<_Effect2>());

      await sub.cancel();
      emitter.dispose();
    });

    test('emit is safe after dispose — no throw', () {
      final emitter = EffectEmitter<_Effect>();
      emitter.dispose();
      expect(emitter.isDisposed, true);
      expect(() => emitter.emit(const _Effect()), returnsNormally);
    });

    test('hasListener reports subscription state', () async {
      final emitter = EffectEmitter<_Effect>();
      expect(emitter.hasListener, false);

      final sub = emitter.stream.listen((_) {});
      // Broadcast stream may set hasListener asynchronously; pump microtasks.
      await Future(() {});
      expect(emitter.hasListener, true);

      await sub.cancel();
      await Future(() {});
      // After cancel, hasListener may still be true briefly; that is OK.
      emitter.dispose();
    });

    test('isDisposed reflects dispose call', () {
      final emitter = EffectEmitter<_Effect>();
      expect(emitter.isDisposed, false);
      emitter.dispose();
      expect(emitter.isDisposed, true);
    });

    test('listen method subscribes from non-widget code', () async {
      final emitter = EffectEmitter<_Effect>();
      final effects = <_Effect>[];
      final sub = emitter.listen(effects.add);

      emitter.emit(const _Effect());
      await Future(() {});
      expect(effects, hasLength(1));

      await sub.cancel();
      emitter.dispose();
    });

    group('replay', () {
      test('replays past effects to late listener', () async {
        final emitter = EffectEmitter<_Effect>(replay: 5);

        emitter.emit(const _Effect());
        emitter.emit(const _Effect2());

        final effects = <_Effect>[];
        final sub = emitter.stream.listen(effects.add);
        await Future(() {});
        expect(effects, hasLength(2));

        await sub.cancel();
        emitter.dispose();
      });

      test('respects replay limit', () async {
        final emitter = EffectEmitter<_Effect>(replay: 2);

        emitter.emit(const _Effect());
        emitter.emit(const _Effect());
        emitter.emit(const _Effect2());

        final effects = <_Effect>[];
        final sub = emitter.stream.listen(effects.add);
        await Future(() {});
        // Only last 2 effects are replayed
      expect(effects, hasLength(2));
      expect(effects[0], isA<_Effect>());
      expect(effects[1], isA<_Effect2>());

        await sub.cancel();
        emitter.dispose();
      });

      test('no replay when replay is 0', () async {
        final emitter = EffectEmitter<_Effect>(replay: 0);

        emitter.emit(const _Effect());

        final effects = <_Effect>[];
        final sub = emitter.stream.listen(effects.add);
        await Future(() {});
        expect(effects, isEmpty);

        await sub.cancel();
        emitter.dispose();
      });
    });
  });
}

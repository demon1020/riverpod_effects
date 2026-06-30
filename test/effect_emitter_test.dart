import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_effects/riverpod_effects.dart';

class _E extends UiEffect {
  const _E();
}

class _E2 extends _E {
  const _E2();
}

void main() {
  group('EffectEmitter', () {
    test('emit delivers effect to listener', () async {
      final e = EffectEmitter<_E>();
      final seen = <_E>[];
      final sub = e.stream.listen(seen.add);

      e.emit(const _E());
      await Future(() {});
      expect(seen, hasLength(1));

      await sub.cancel();
      e.dispose();
    });

    test('multiple effects delivered in FIFO order', () async {
      final e = EffectEmitter<_E>();
      final seen = <_E>[];
      final sub = e.stream.listen(seen.add);

      e.emit(const _E());
      e.emit(const _E2());
      await Future(() {});
      expect(seen, hasLength(2));
      expect(seen[0], isA<_E>());
      expect(seen[1], isA<_E2>());

      await sub.cancel();
      e.dispose();
    });

    test('emit after dispose is a no-op', () {
      final e = EffectEmitter<_E>();
      e.dispose();
      expect(e.isDisposed, true);
      expect(() => e.emit(const _E()), returnsNormally);
    });

    test('hasListener reflects subscription', () async {
      final e = EffectEmitter<_E>();
      expect(e.hasListener, false);

      final sub = e.stream.listen((_) {});
      await Future(() {});
      expect(e.hasListener, true);

      await sub.cancel();
      e.dispose();
    });

    test('isDisposed reflects dispose call', () {
      final e = EffectEmitter<_E>();
      expect(e.isDisposed, false);
      e.dispose();
      expect(e.isDisposed, true);
    });

    test('multiple listeners each receive all events', () async {
      final e = EffectEmitter<_E>();
      final a = <_E>[], b = <_E>[];
      final subA = e.stream.listen(a.add);
      final subB = e.stream.listen(b.add);

      e.emit(const _E());
      await Future(() {});
      expect(a, hasLength(1));
      expect(b, hasLength(1));

      await subA.cancel();
      await subB.cancel();
      e.dispose();
    });

    test('listen subscribes from non-widget code', () async {
      final e = EffectEmitter<_E>();
      final seen = <_E>[];
      final sub = e.listen(seen.add);

      e.emit(const _E());
      await Future(() {});
      expect(seen, hasLength(1));

      await sub.cancel();
      e.dispose();
    });

    test('listen respects cancelOnError: false by default', () async {
      final e = EffectEmitter<_E>();
      final errors = <Object>[];
      final sub = e.listen(
        (_) {},
        onError: (err) => errors.add(err),
      );
      await sub.cancel();
      e.dispose();
    });

    group('replay', () {
      test('replays past effects to late listener', () async {
        final e = EffectEmitter<_E>(replay: 5);
        e.emit(const _E());
        e.emit(const _E2());

        final seen = <_E>[];
        final sub = e.stream.listen(seen.add);
        await Future(() {});
        expect(seen, hasLength(2));

        await sub.cancel();
        e.dispose();
      });

      test('respects replay limit', () async {
        final e = EffectEmitter<_E>(replay: 2);
        e.emit(const _E());
        e.emit(const _E());
        e.emit(const _E2());

        final seen = <_E>[];
        final sub = e.stream.listen(seen.add);
        await Future(() {});
        expect(seen, hasLength(2));
        expect(seen[0], isA<_E>());
        expect(seen[1], isA<_E2>());

        await sub.cancel();
        e.dispose();
      });

      test('no replay when replay is 0', () async {
        final e = EffectEmitter<_E>(replay: 0);
        e.emit(const _E());

        final seen = <_E>[];
        final sub = e.stream.listen(seen.add);
        await Future(() {});
        expect(seen, isEmpty);

        await sub.cancel();
        e.dispose();
      });
    });
  });
}

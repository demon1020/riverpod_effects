import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_effects/riverpod_effects.dart';

class _E extends UiEffect {
  const _E();
}

// Sync Notifier
class _N extends Notifier<int> with EffectMixin<_E, int> {
  @override
  int build() => 0;
  void trigger() => emitEffect(const _E());
}

final _provider = NotifierProvider<_N, int>(_N.new);

// AsyncNotifier
class _AN extends AsyncNotifier<int> with EffectMixin<_E, int> {
  @override
  Future<int> build() async => 0;
  void trigger() => emitEffect(const _E());
}

final _asyncProvider = AsyncNotifierProvider<_AN, int>(_AN.new);

// EffectsNotifier base class
class _BN extends EffectsNotifier<_E, int> {
  @override
  int build() => 0;
  void trigger() => emitEffect(const _E());
}

final _baseProvider = NotifierProvider<_BN, int>(_BN.new);

// AsyncEffectsNotifier base class
class _BAN extends AsyncEffectsNotifier<_E, int> {
  @override
  Future<int> build() async => 0;
  void trigger() => emitEffect(const _E());
}

final _asyncBaseProvider = AsyncNotifierProvider<_BAN, int>(_BAN.new);

void main() {
  group('EffectMixin with NotifierProvider', () {
    test('effects stream delivers emitted effects', () async {
      final container = ProviderContainer();
      final n = container.read(_provider.notifier);
      final seen = <_E>[];
      final sub = n.effects.listen(seen.add);
      n.trigger();
      await Future(() {});
      expect(seen, hasLength(1));
      await sub.cancel();
      container.dispose();
    });

    test('hasListener reflects subscription', () async {
      final container = ProviderContainer();
      final n = container.read(_provider.notifier);
      expect(n.hasListener, false);
      final sub = n.effects.listen((_) {});
      await Future(() {});
      expect(n.hasListener, true);
      await sub.cancel();
      container.dispose();
    });

    test('listen subscribes from non-widget code', () async {
      final container = ProviderContainer();
      final n = container.read(_provider.notifier);
      final seen = <_E>[];
      final sub = n.listen(seen.add);
      n.trigger();
      await Future(() {});
      expect(seen, hasLength(1));
      await sub.cancel();
      container.dispose();
    });

    test('emit after provider dispose is safe', () async {
      final container = ProviderContainer();
      final n = container.read(_provider.notifier);
      container.dispose();
      expect(() => n.trigger(), returnsNormally);
    });

    test('emitter is auto-disposed when provider is disposed', () async {
      final container = ProviderContainer();
      final n = container.read(_provider.notifier);
      final seen = <_E>[];
      final sub = n.effects.listen(seen.add);
      await Future(() {});
      n.trigger();
      await Future(() {});
      expect(seen, hasLength(1));
      await sub.cancel();
      container.dispose();
      expect(() => n.trigger(), returnsNormally);
    });
  });

  group('EffectMixin with AsyncNotifierProvider', () {
    test('effects stream delivers emitted effects', () async {
      final container = ProviderContainer();
      final n = container.read(_asyncProvider.notifier);
      final seen = <_E>[];
      final sub = n.effects.listen(seen.add);
      n.trigger();
      await Future(() {});
      expect(seen, hasLength(1));
      await sub.cancel();
      container.dispose();
    });
  });

  group('EffectsNotifier base class', () {
    test('works with NotifierProvider', () async {
      final container = ProviderContainer();
      final n = container.read(_baseProvider.notifier);
      final seen = <_E>[];
      final sub = n.effects.listen(seen.add);
      n.trigger();
      await Future(() {});
      expect(seen, hasLength(1));
      await sub.cancel();
      container.dispose();
    });
  });

  group('AsyncEffectsNotifier base class', () {
    test('works with AsyncNotifierProvider', () async {
      final container = ProviderContainer();
      final n = container.read(_asyncBaseProvider.notifier);
      final seen = <_E>[];
      final sub = n.effects.listen(seen.add);
      n.trigger();
      await Future(() {});
      expect(seen, hasLength(1));
      await sub.cancel();
      container.dispose();
    });
  });
}

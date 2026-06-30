import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_effects/riverpod_effects.dart';

class _TestEffect extends UiEffect {
  const _TestEffect();
}

class _TestNotifier extends Notifier<int> with EffectMixin<_TestEffect, int> {
  @override
  int build() => 0;

  void trigger() => emitEffect(const _TestEffect());
}

final _testProvider = NotifierProvider<_TestNotifier, int>(
  _TestNotifier.new,
);

void main() {
  group('EffectMixin', () {
    test('effects stream delivers emitted effects', () async {
      final container = ProviderContainer(overrides: []);
      final notifier = container.read(_testProvider.notifier);

      final effects = <_TestEffect>[];
      final sub = notifier.effects.listen(effects.add);

      notifier.trigger();
      await Future(() {});
      expect(effects, hasLength(1));

      await sub.cancel();
      container.dispose();
    });

    test('hasListener reflects subscription', () async {
      final container = ProviderContainer(overrides: []);
      final notifier = container.read(_testProvider.notifier);

      expect(notifier.hasListener, false);

      final sub = notifier.effects.listen((_) {});
      await Future(() {});
      expect(notifier.hasListener, true);

      await sub.cancel();
      container.dispose();
    });

    test('listen method subscribes from non-widget code', () async {
      final container = ProviderContainer(overrides: []);
      final notifier = container.read(_testProvider.notifier);

      final effects = <_TestEffect>[];
      final sub = notifier.listen(effects.add);

      notifier.trigger();
      await Future(() {});
      expect(effects, hasLength(1));

      await sub.cancel();
      container.dispose();
    });

    test('emit after provider dispose is safe', () async {
      final container = ProviderContainer(overrides: []);
      final notifier = container.read(_testProvider.notifier);

      container.dispose();

      // Should not throw even though the emitter is disposed
      expect(() => notifier.trigger(), returnsNormally);
    });

    test('emitter is disposed when provider is disposed', () async {
      final container = ProviderContainer(overrides: []);
      final notifier = container.read(_testProvider.notifier);

      // Verify it works before dispose
      final effects = <_TestEffect>[];
      final sub = notifier.effects.listen(effects.add);
      await Future(() {});

      notifier.trigger();
      await Future(() {});
      expect(effects, hasLength(1));

      // After dispose, the emitter is auto-cleaned
      await sub.cancel();
      container.dispose();

      // Further emits are no-ops
      expect(() => notifier.trigger(), returnsNormally);
    });
  });
}

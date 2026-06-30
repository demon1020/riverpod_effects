import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_effects/riverpod_effects.dart';

class _E extends UiEffect {
  const _E();
}

Widget _consumer(
  Stream<_E> stream,
  void Function(BuildContext, _E) listener,
  WidgetBuilder builder,
) =>
    MaterialApp(
      home: EffectConsumer<_E>(
        stream: stream,
        listener: listener,
        builder: builder,
      ),
    );

void main() {
  group('EffectConsumer', () {
    testWidgets('delivers effects to listener', (tester) async {
      final c = StreamController<_E>.broadcast();
      final delivered = <_E>[];

      await tester.pumpWidget(_consumer(
        c.stream,
        (_, e) => delivered.add(e),
        (_) => const SizedBox(),
      ));

      c.add(const _E());
      await tester.pump();
      expect(delivered, hasLength(1));

      await c.close();
    });

    testWidgets('builder renders child widget', (tester) async {
      final c = StreamController<_E>.broadcast();

      await tester.pumpWidget(_consumer(
        c.stream,
        (_, _) {},
        (_) => const Text('child'),
      ));

      expect(find.text('child'), findsOneWidget);
      await c.close();
    });

    testWidgets('handles multiple effects', (tester) async {
      final c = StreamController<_E>.broadcast();
      final delivered = <_E>[];

      await tester.pumpWidget(_consumer(
        c.stream,
        (_, e) => delivered.add(e),
        (_) => const SizedBox(),
      ));

      c.add(const _E());
      c.add(const _E());
      await tester.pump();
      expect(delivered, hasLength(2));

      await c.close();
    });

    testWidgets('cancels subscription on unmount', (tester) async {
      final c = StreamController<_E>.broadcast();

      await tester.pumpWidget(_consumer(
        c.stream,
        (_, _) {},
        (_) => const SizedBox(),
      ));

      await tester.pumpWidget(const SizedBox());
      expect(() => c.add(const _E()), returnsNormally);
      await tester.pump();
      await c.close();
    });
  });
}

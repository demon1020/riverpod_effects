import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_effects/riverpod_effects.dart';

class _Effect extends UiEffect {
  const _Effect();
}

Widget _consumerWidget(
  Stream<_Effect> stream,
  void Function(BuildContext, _Effect) listener,
  WidgetBuilder builder,
) =>
    MaterialApp(
      home: EffectConsumer<_Effect>(
        stream: stream,
        listener: listener,
        builder: builder,
      ),
    );

void main() {
  group('EffectConsumer', () {
    testWidgets('delivers effects to listener', (tester) async {
      final controller = StreamController<_Effect>.broadcast();
      final delivered = <_Effect>[];

      await tester.pumpWidget(_consumerWidget(
        controller.stream,
        (_, effect) => delivered.add(effect),
        (_) => const SizedBox(),
      ));

      controller.add(const _Effect());
      await tester.pump();
      expect(delivered, hasLength(1));

      await controller.close();
    });

    testWidgets('builder renders the provided widget', (tester) async {
      final controller = StreamController<_Effect>.broadcast();

      await tester.pumpWidget(_consumerWidget(
        controller.stream,
        (_, _) {},
        (_) => const Text('consumer-child'),
      ));

      expect(find.text('consumer-child'), findsOneWidget);
      await controller.close();
    });

    testWidgets('handles multiple effects', (tester) async {
      final controller = StreamController<_Effect>.broadcast();
      final delivered = <_Effect>[];

      await tester.pumpWidget(_consumerWidget(
        controller.stream,
        (_, effect) => delivered.add(effect),
        (_) => const SizedBox(),
      ));

      controller.add(const _Effect());
      controller.add(const _Effect());
      await tester.pump();
      expect(delivered, hasLength(2));

      await controller.close();
    });

    testWidgets('cancels subscription on unmount', (tester) async {
      final controller = StreamController<_Effect>.broadcast();

      await tester.pumpWidget(_consumerWidget(
        controller.stream,
        (_, _) {},
        (_) => const SizedBox(),
      ));

      await tester.pumpWidget(const SizedBox());

      // Should not throw or leak
      controller.add(const _Effect());
      await tester.pump();

      await controller.close();
    });
  });
}

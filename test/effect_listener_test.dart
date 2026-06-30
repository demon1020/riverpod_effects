import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_effects/riverpod_effects.dart';

class _Effect extends UiEffect {
  const _Effect();
}

Widget _listenerWidget(
  Stream<_Effect> stream,
  void Function(BuildContext, _Effect) listener, {
  Widget child = const SizedBox(),
}) =>
    MaterialApp(
      home: EffectListener<_Effect>(
        stream: stream,
        listener: listener,
        child: child,
      ),
    );

void main() {
  group('EffectListener', () {
    testWidgets('delivers effects to listener', (tester) async {
      final controller = StreamController<_Effect>.broadcast();
      final delivered = <_Effect>[];

      await tester.pumpWidget(_listenerWidget(
        controller.stream,
        (_, effect) => delivered.add(effect),
      ));

      controller.add(const _Effect());
      await tester.pump();
      expect(delivered, hasLength(1));

      await controller.close();
    });

    testWidgets('delivers multiple effects in order', (tester) async {
      final controller = StreamController<_Effect>.broadcast();
      final delivered = <_Effect>[];

      await tester.pumpWidget(_listenerWidget(
        controller.stream,
        (_, effect) => delivered.add(effect),
      ));

      controller.add(const _Effect());
      controller.add(const _Effect());
      controller.add(const _Effect());
      await tester.pump();
      expect(delivered, hasLength(3));

      await controller.close();
    });

    testWidgets('cancels subscription on unmount — no crash on late emit',
        (tester) async {
      final controller = StreamController<_Effect>.broadcast();

      await tester.pumpWidget(_listenerWidget(
        controller.stream,
        (_, _) {},
      ));

      // Unmount the listener
      await tester.pumpWidget(const SizedBox());

      // Should not throw
      controller.add(const _Effect());
      await tester.pump();

      await controller.close();
    });

    testWidgets('re-subscribes when stream reference changes',
        (tester) async {
      final controller1 = StreamController<_Effect>.broadcast();
      final controller2 = StreamController<_Effect>.broadcast();
      final delivered = <_Effect>[];

      await tester.pumpWidget(_listenerWidget(
        controller1.stream,
        (_, effect) => delivered.add(effect),
      ));

      controller1.add(const _Effect());
      await tester.pump();
      expect(delivered, hasLength(1));

      // Switch to a different stream
      await tester.pumpWidget(_listenerWidget(
        controller2.stream,
        (_, effect) => delivered.add(effect),
      ));

      // Old stream events should not reach listener
      controller1.add(const _Effect());
      await tester.pump();
      expect(delivered, hasLength(1));

      // New stream events should reach listener
      controller2.add(const _Effect());
      await tester.pump();
      expect(delivered, hasLength(2));

      await controller1.close();
      await controller2.close();
    });

    testWidgets('renders child widget', (tester) async {
      final controller = StreamController<_Effect>.broadcast();

      await tester.pumpWidget(_listenerWidget(
        controller.stream,
        (_, _) {},
        child: const Text('hello'),
      ));

      expect(find.text('hello'), findsOneWidget);
      await controller.close();
    });

    testWidgets('handles stream errors without crashing', (tester) async {
      final controller = StreamController<_Effect>.broadcast();
      final errors = <FlutterErrorDetails>[];
      final originalOnError = FlutterError.onError;
      FlutterError.onError = errors.add;

      await tester.pumpWidget(_listenerWidget(
        controller.stream,
        (_, _) {},
      ));

      // Should not cause a crash — error is reported via FlutterError
      controller.addError(Exception('test error'));
      await tester.pump();

      expect(errors, hasLength(1));
      expect(errors.first.exceptionAsString(), contains('test error'));

      FlutterError.onError = originalOnError;
      await controller.close();
    });
  });
}

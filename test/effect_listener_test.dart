import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_effects/riverpod_effects.dart';

class _E extends UiEffect {
  const _E();
}

Widget _listener(
  Stream<_E> stream,
  void Function(BuildContext, _E) listener, {
  Widget child = const SizedBox(),
}) => MaterialApp(
  home: EffectListener<_E>(stream: stream, listener: listener, child: child),
);

void main() {
  group('EffectListener', () {
    testWidgets('delivers effects to listener', (tester) async {
      final c = StreamController<_E>.broadcast();
      final delivered = <_E>[];

      await tester.pumpWidget(_listener(c.stream, (_, e) => delivered.add(e)));

      c.add(const _E());
      await tester.pump();
      expect(delivered, hasLength(1));

      await c.close();
    });

    testWidgets('delivers multiple effects in order', (tester) async {
      final c = StreamController<_E>.broadcast();
      final delivered = <_E>[];

      await tester.pumpWidget(_listener(c.stream, (_, e) => delivered.add(e)));
      c.add(const _E());
      c.add(const _E());
      c.add(const _E());
      await tester.pump();
      expect(delivered, hasLength(3));

      await c.close();
    });

    testWidgets('cancels subscription on unmount — no crash', (tester) async {
      final c = StreamController<_E>.broadcast();

      await tester.pumpWidget(_listener(c.stream, (_, _) {}));
      await tester.pumpWidget(const SizedBox());

      expect(() => c.add(const _E()), returnsNormally);
      await tester.pump();
      await c.close();
    });

    testWidgets('re-subscribes when stream changes', (tester) async {
      final c1 = StreamController<_E>.broadcast();
      final c2 = StreamController<_E>.broadcast();
      final delivered = <_E>[];

      await tester.pumpWidget(_listener(c1.stream, (_, e) => delivered.add(e)));
      c1.add(const _E());
      await tester.pump();
      expect(delivered, hasLength(1));

      // Switch stream
      await tester.pumpWidget(_listener(c2.stream, (_, e) => delivered.add(e)));

      // Old stream ignored
      c1.add(const _E());
      await tester.pump();
      expect(delivered, hasLength(1));

      // New stream received
      c2.add(const _E());
      await tester.pump();
      expect(delivered, hasLength(2));

      await c1.close();
      await c2.close();
    });

    testWidgets('renders child widget', (tester) async {
      final c = StreamController<_E>.broadcast();
      await tester.pumpWidget(
        _listener(c.stream, (_, _) {}, child: const Text('child')),
      );
      expect(find.text('child'), findsOneWidget);
      await c.close();
    });

    testWidgets('reports stream errors without crashing', (tester) async {
      final c = StreamController<_E>.broadcast();
      final errors = <FlutterErrorDetails>[];
      final original = FlutterError.onError;
      FlutterError.onError = errors.add;

      await tester.pumpWidget(_listener(c.stream, (_, _) {}));
      c.addError(Exception('fail'));
      await tester.pump();

      expect(errors, hasLength(1));
      expect(errors.first.exceptionAsString(), contains('fail'));

      FlutterError.onError = original;
      await c.close();
    });
  });
}

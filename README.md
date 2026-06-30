# riverpod_effects

One-time side effects (navigation, snackbars, dialogs) for Riverpod.

Emit ephemeral UI events without storing them in your notifier state. Effects
are delivered exactly once, never cause rebuilds, and are automatically cleaned
up when the notifier is disposed.

---

## Requirements

- Dart 3.8+ / Flutter 3.29+
- Riverpod 3.0+
- Platforms: Android, iOS, Linux, macOS, Web, Windows

---

## Install

```yaml
dependencies:
  riverpod_effects: ^1.0.0
```

---

## Quick start

### 1. Define your effects

```dart
import 'package:riverpod_effects/riverpod_effects.dart';

sealed class MyEffect extends UiEffect {
  const MyEffect();
}

class ShowSnackBar extends MyEffect {
  final String message;
  const ShowSnackBar(this.message);
}

class NavigateHome extends MyEffect {
  const NavigateHome();
}
```

### 2. Add the mixin to your notifier

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod_effects/riverpod_effects.dart';

part 'my_view_model.g.dart';

@riverpod
class MyViewModel extends _$MyViewModel with EffectMixin<MyEffect, int> {
  @override
  int build() => 0;

  void save() {
    emitEffect(const ShowSnackBar('Saved!'));
    emitEffect(const NavigateHome());
  }
}
```

The second type parameter (`int`) matches your notifier's state type.

### 3. Listen in the UI

```dart
class MyPage extends ConsumerWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(myViewModelProvider.notifier);
    final state = ref.watch(myViewModelProvider);

    return EffectConsumer<MyEffect>(
      stream: notifier.effects,
      listener: (context, effect) {
        switch (effect) {
          case NavigateHome():
            context.go('/home');
          case ShowSnackBar(message: final msg):
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(msg)),
            );
        }
      },
      builder: (context) {
        return Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () => notifier.save(),
              child: Text('Save ($state)'),
            ),
          ),
        );
      },
    );
  }
}
```

---

## How it works

```
UI
 │
 ▼
EffectConsumer        ← subscribes to notifier.effects
 │
 ▼
EffectListener       ← manages stream lifecycle (subscribe / cancel)
 │
 ▼
notifier.effects     ← broadcast stream from EffectMixin
 │
 ▲
 emitEffect()        ← called from notifier methods
 │
EffectMixin          ← mixed into your notifier (auto-disposed)
```

- Effects are delivered **exactly once** per listener.
- Effects **never rebuild the UI** — they are not part of state.
- Effects are delivered in **FIFO** order.
- Stream errors are caught and reported via `FlutterError` (they never crash the
  widget tree).

---

## API

| Class | Purpose |
|-------|---------|
| `UiEffect` | Base class for every effect. |
| `EffectMixin<E, T>` | Mixin for any Riverpod notifier (sync or async). Provides `emitEffect()`, `effects`, `hasListener`, `listen()`. Lifecycle is automatic. |
| `EffectsNotifier<E, T>` | Base class extending `Notifier<T>` with effect support pre-applied. |
| `AsyncEffectsNotifier<E, T>` | Base class extending `AsyncNotifier<T>` with effect support pre-applied. |
| `EffectConsumer<E>` | Widget that listens to effects and builds UI. |
| `EffectListener<E>` | Low-level stateful widget that subscribes to an effect stream. |
| `EffectEmitter<E>` | Stream-based emitter. Supports optional `replay` of past effects. |

---

## Advanced

### Replay effects for late listeners

By default, effects emitted before a widget subscribes are lost. Override the
emitter in your notifier to buffer past effects:

```dart
class MyViewModel extends _$MyViewModel with EffectMixin<MyEffect, int> {
  @override
  EffectEmitter<MyEffect> createEffectEmitter() =>
      EffectEmitter<MyEffect>(replay: 5);
}
```

### Check if anyone is listening

```dart
if (hasListener) {
  emitEffect(const ExpensiveEffect());
}
```

### Subscribe from non-widget code

```dart
final sub = notifier.listen((effect) {
  // handle effect in a service or another notifier
});
// later: sub.cancel();
```

---

## Example

A complete runnable example is in [`example/`](example/). Run it with:

```bash
cd example
flutter run
```

Enter `admin` / `admin` to see a snackbar and navigate to the home screen.

---

## License

MIT

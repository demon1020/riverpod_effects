# riverpod_effects

Bloc-like one-time side effects for Riverpod.

Emit ephemeral UI events — navigation, snackbars, dialogs, permission requests, URL launches — without storing them in your state.

Works with **Riverpod Generator** (`@riverpod`), **Notifier**, and **AsyncNotifier**.

---

## Install

```yaml
dependencies:
  riverpod_effects: ^0.0.1
```

---

## Quick Start

### 1. Define your effects

Create a sealed class extending `UiEffect`:

```dart
import 'package:riverpod_effects/riverpod_effects.dart';

sealed class MyEffect extends UiEffect {
  const MyEffect();
}

class NavigateToHome extends MyEffect {
  const NavigateToHome();
}

class ShowSnackBar extends MyEffect {
  final String message;
  const ShowSnackBar(this.message);
}
```

### 2. Add the mixin to your ViewModel

Mix `EffectMixin<MyEffect, int>` into your Riverpod-generated notifier — the effect stream is automatically disposed when the notifier is disposed:

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod_effects/riverpod_effects.dart';

part 'my_view_model.g.dart';

@riverpod
class MyViewModel extends _$MyViewModel with EffectMixin<MyEffect, int> {
  @override
  int build() => 0;

  Future<void> save() async {
    // ... do work ...
    emitEffect(const ShowSnackBar('Saved!'));
    emitEffect(const NavigateToHome());
  }
}
```

### 3. Listen in the UI

Wrap your widget tree with `EffectConsumer`:

```dart
class MyPage extends ConsumerWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(myViewModelProvider);
    final notifier = ref.read(myViewModelProvider.notifier);

    return EffectConsumer<MyEffect>(
      stream: notifier.effects,
      listener: (context, effect) {
        switch (effect) {
          case NavigateToHome():
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
EffectConsumer        ← listens to the effect stream
 │
 ▼
EffectListener        ← subscribes once, cancels on dispose
 │
 ▼
ViewModel.effects     ← broadcast stream from EffectMixin
 │
 ▲
 emitEffect()         ← called from ViewModel methods
 │
EffectMixin           ← owned by your ViewModel
```

- Effects are delivered **exactly once** per listener.
- Effects never rebuild the UI — they are **not part of state**.
- Effects are delivered in **FIFO order**.
- Stream errors are caught and reported via `FlutterError` (they never crash the widget tree).

---

## API

| Class | Purpose |
|-------|---------|
| `UiEffect` | Base class for every effect. |
| `EffectMixin<E>` | Mixin for Riverpod ViewModels. Provides `emitEffect()`, `effects`, `disposeEffects()`, `hasListener`, `listen()`, `initEffects(ref)`. |
| `EffectConsumer<E>` | Widget that listens to effects and builds UI. |
| `EffectListener<E>` | Low-level stateful widget that subscribes to an effect stream. |
| `EffectEmitter<E>` | Stream-based emitter. Supports optional `replay` of past effects for late listeners. |

---

## Advanced

### Replay effects for late listeners

By default, effects emitted before a widget subscribes are lost. To buffer past
effects, pass `replay:` to `EffectEmitter`:

```dart
mixin EffectMixin<E extends UiEffect> {
  // Override in your notifier to enable replay:
  final EffectEmitter<E> _emitter = EffectEmitter<E>(replay: 5);
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

A complete runnable example is available in the [`example/`](example/) directory:

```bash
cd example
flutter run
```

Enter `admin` / `admin` to see a snackbar and navigate to the home screen.

---

## License

MIT

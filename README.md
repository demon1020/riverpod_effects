# riverpod_effects

Bloc-like one-time side effects for Riverpod.

Emit ephemeral UI events — navigation, snackbars, dialogs, permission requests, URL launches — without storing them in your state.

Works with **Riverpod Generator** (`@riverpod`), **Notifier**, and **AsyncNotifier**.

---

## Install

```yaml
dependencies:
  riverpod_effects: ^0.1.0
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

Mix `EffectMixin<MyEffect>` into your Riverpod-generated notifier:

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod_effects/riverpod_effects.dart';

part 'my_view_model.g.dart';

@riverpod
class MyViewModel extends _$MyViewModel with EffectMixin<MyEffect> {
  @override
  int build() {
    ref.onDispose(disposeEffects);    // <-- clean up on dispose
    return 0;
  }

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

- Effects are delivered **exactly once**.
- Effects never rebuild the UI — they are **not part of state**.

---

## API

| Class | Purpose |
|-------|---------|
| `UiEffect` | Base class for every effect. |
| `EffectMixin<E>` | Mixin for Riverpod ViewModels. Provides `emitEffect()`, `effects`, `disposeEffects()`. |
| `EffectConsumer<E>` | Widget that listens to effects and builds UI. |
| `EffectListener<E>` | Low-level stateful widget that subscribes to an effect stream. |
| `EffectEmitter<E>` | Stream-based emitter (used internally by `EffectMixin`). |
| `EffectNotifier<E>` | Abstract contract for notifiers that expose an `effects` stream. |

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

## 1.0.0

- **Unified `EffectMixin`** — single mixin works for both sync `Notifier` and
  `AsyncNotifier`. Replaces the previous `EffectMixin` + `AsyncEffectMixin`.
- `EffectsNotifier<E, T>` — base class extending `Notifier<T>` with effects
  pre-applied.
- `AsyncEffectsNotifier<E, T>` — base class extending `AsyncNotifier<T>` with
  effects pre-applied.
- `createEffectEmitter()` — overridable factory for configuring `replay`.
- Lazy emitter initialization — emitter is created on first access, not during
  `runBuild()`. This avoids the need for `on AnyNotifier` constraints.

## 0.0.1

- Initial release.
- `UiEffect` — base class for one-time effects.
- `EffectMixin` — mixin for sync Riverpod notifiers with automatic lifecycle.
- `AsyncEffectMixin` — mixin for async Riverpod notifiers.
- `EffectConsumer` — widget to listen and react to effects in the UI.
- `EffectListener` — low-level stateful listener widget.
- `EffectEmitter` — stream-based effect emitter with optional replay.

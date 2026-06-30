## 0.1.0

- Initial release.
- `UiEffect` — base class for one-time effects.
- `EffectMixin` — mixin for Riverpod ViewModels with `emitEffect()`.
- `EffectConsumer` — widget to listen and react to effects in the UI.
- `EffectListener` — low-level stateful listener widget.
- `EffectEmitter` — stream-based effect emitter (used internally by the mixin).
- `EffectNotifier` — abstract contract for notifiers that emit effects.

/// Base class for all UI effects.
///
/// Effects are ephemeral, one-time events — like navigation, snackbars,
/// dialogs, or permission requests — that are emitted outside of state.
///
/// Define your application's effects as a sealed hierarchy:
/// ```dart
/// sealed class MyEffect extends UiEffect {
///   const MyEffect();
/// }
///
/// class ShowSnackBar extends MyEffect {
///   final String message;
///   const ShowSnackBar(this.message);
/// }
/// ```
abstract class UiEffect {
  const UiEffect();
}

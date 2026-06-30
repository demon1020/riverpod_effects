import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod/riverpod.dart';

part 'home_state.freezed.dart';

@freezed
sealed class HomeState with _$HomeState {
  const factory HomeState({
    @Default(AsyncValue<String>.loading())
    AsyncValue<String> homeState,
  }) = _HomeState;
}

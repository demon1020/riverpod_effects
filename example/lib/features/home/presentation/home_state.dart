import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod/riverpod.dart';

import 'home_entity.dart';

part 'home_state.freezed.dart';

@freezed
sealed class HomeState with _$HomeState {
  const factory HomeState({
    @Default(AsyncValue<HomeEntity>.loading())
    AsyncValue<HomeEntity> homeState,
  }) = _HomeState;
}

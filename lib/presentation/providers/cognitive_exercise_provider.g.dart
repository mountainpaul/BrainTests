// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cognitive_exercise_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CognitiveExerciseNotifier)
const cognitiveExerciseProvider = CognitiveExerciseNotifierProvider._();

final class CognitiveExerciseNotifierProvider
    extends $AsyncNotifierProvider<CognitiveExerciseNotifier, void> {
  const CognitiveExerciseNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'cognitiveExerciseProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$cognitiveExerciseNotifierHash();

  @$internal
  @override
  CognitiveExerciseNotifier create() => CognitiveExerciseNotifier();
}

String _$cognitiveExerciseNotifierHash() =>
    r'eed293aee1969b8d661941e6d2a101b5973d034c';

abstract class _$CognitiveExerciseNotifier extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    build();
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<void>, void>,
        AsyncValue<void>,
        Object?,
        Object?>;
    element.handleValue(ref, null);
  }
}

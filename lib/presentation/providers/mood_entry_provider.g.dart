// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mood_entry_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(MoodEntryNotifier)
const moodEntryProvider = MoodEntryNotifierProvider._();

final class MoodEntryNotifierProvider
    extends $AsyncNotifierProvider<MoodEntryNotifier, void> {
  const MoodEntryNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'moodEntryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$moodEntryNotifierHash();

  @$internal
  @override
  MoodEntryNotifier create() => MoodEntryNotifier();
}

String _$moodEntryNotifierHash() => r'86825e1adfa170f3fb53e7880b8fe6c8dee66b5e';

abstract class _$MoodEntryNotifier extends $AsyncNotifier<void> {
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

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reminder_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ReminderNotifier)
const reminderProvider = ReminderNotifierProvider._();

final class ReminderNotifierProvider
    extends $AsyncNotifierProvider<ReminderNotifier, void> {
  const ReminderNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'reminderProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$reminderNotifierHash();

  @$internal
  @override
  ReminderNotifier create() => ReminderNotifier();
}

String _$reminderNotifierHash() => r'bb6f52ac63a8e833d17ae666fde740a4f5ae3d18';

abstract class _$ReminderNotifier extends $AsyncNotifier<void> {
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

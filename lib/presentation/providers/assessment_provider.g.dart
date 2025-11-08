// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assessment_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AssessmentNotifier)
const assessmentProvider = AssessmentNotifierProvider._();

final class AssessmentNotifierProvider
    extends $AsyncNotifierProvider<AssessmentNotifier, void> {
  const AssessmentNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'assessmentProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$assessmentNotifierHash();

  @$internal
  @override
  AssessmentNotifier create() => AssessmentNotifier();
}

String _$assessmentNotifierHash() =>
    r'3b2ce08daabb8f170e19080eb905bdfe4bfd235e';

abstract class _$AssessmentNotifier extends $AsyncNotifier<void> {
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

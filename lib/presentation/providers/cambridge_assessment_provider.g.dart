// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cambridge_assessment_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CambridgeAssessment)
const cambridgeAssessmentProvider = CambridgeAssessmentProvider._();

final class CambridgeAssessmentProvider extends $AsyncNotifierProvider<
    CambridgeAssessment, List<CambridgeAssessmentResult>> {
  const CambridgeAssessmentProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'cambridgeAssessmentProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$cambridgeAssessmentHash();

  @$internal
  @override
  CambridgeAssessment create() => CambridgeAssessment();
}

String _$cambridgeAssessmentHash() =>
    r'6f06cce92f5e900c1c6f37c58424c0e416b3522f';

abstract class _$CambridgeAssessment
    extends $AsyncNotifier<List<CambridgeAssessmentResult>> {
  FutureOr<List<CambridgeAssessmentResult>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<List<CambridgeAssessmentResult>>,
        List<CambridgeAssessmentResult>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<CambridgeAssessmentResult>>,
            List<CambridgeAssessmentResult>>,
        AsyncValue<List<CambridgeAssessmentResult>>,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}

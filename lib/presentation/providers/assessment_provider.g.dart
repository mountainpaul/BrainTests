// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assessment_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider to count MCI tests completed this week
/// MCI tests include all assessment types:
/// - Processing Speed (Trail Making Test A)
/// - Executive Function (Trail Making Test B)
/// - Language Skills
/// - Visuospatial Skills
/// - Memory Recall
/// Refresh trigger - increments every time assessments change

@ProviderFor(AssessmentRefreshTrigger)
const assessmentRefreshTriggerProvider = AssessmentRefreshTriggerProvider._();

/// Provider to count MCI tests completed this week
/// MCI tests include all assessment types:
/// - Processing Speed (Trail Making Test A)
/// - Executive Function (Trail Making Test B)
/// - Language Skills
/// - Visuospatial Skills
/// - Memory Recall
/// Refresh trigger - increments every time assessments change
final class AssessmentRefreshTriggerProvider
    extends $NotifierProvider<AssessmentRefreshTrigger, int> {
  /// Provider to count MCI tests completed this week
  /// MCI tests include all assessment types:
  /// - Processing Speed (Trail Making Test A)
  /// - Executive Function (Trail Making Test B)
  /// - Language Skills
  /// - Visuospatial Skills
  /// - Memory Recall
  /// Refresh trigger - increments every time assessments change
  const AssessmentRefreshTriggerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'assessmentRefreshTriggerProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$assessmentRefreshTriggerHash();

  @$internal
  @override
  AssessmentRefreshTrigger create() => AssessmentRefreshTrigger();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$assessmentRefreshTriggerHash() =>
    r'd1ad16da852286c158104fd0a5bd06cfb20aea21';

/// Provider to count MCI tests completed this week
/// MCI tests include all assessment types:
/// - Processing Speed (Trail Making Test A)
/// - Executive Function (Trail Making Test B)
/// - Language Skills
/// - Visuospatial Skills
/// - Memory Recall
/// Refresh trigger - increments every time assessments change

abstract class _$AssessmentRefreshTrigger extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<int, int>;
    final element = ref.element
        as $ClassProviderElement<AnyNotifier<int, int>, int, Object?, Object?>;
    element.handleValue(ref, created);
  }
}

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
    r'a73f9bac426c116f373b230cdf3b2761bbfa4f04';

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

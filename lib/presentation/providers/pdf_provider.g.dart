// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pdf_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PDFGeneratorNotifier)
const pDFGeneratorProvider = PDFGeneratorNotifierProvider._();

final class PDFGeneratorNotifierProvider
    extends $AsyncNotifierProvider<PDFGeneratorNotifier, void> {
  const PDFGeneratorNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'pDFGeneratorProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$pDFGeneratorNotifierHash();

  @$internal
  @override
  PDFGeneratorNotifier create() => PDFGeneratorNotifier();
}

String _$pDFGeneratorNotifierHash() =>
    r'e9d16fd0d53b75f406c51e0f0a05a889083f4614';

abstract class _$PDFGeneratorNotifier extends $AsyncNotifier<void> {
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

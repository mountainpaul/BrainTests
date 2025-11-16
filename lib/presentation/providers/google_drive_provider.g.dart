// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'google_drive_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for Google Drive sign-in state
/// Watches for authentication changes and rebuilds UI automatically

@ProviderFor(GoogleDriveAuth)
const googleDriveAuthProvider = GoogleDriveAuthProvider._();

/// Provider for Google Drive sign-in state
/// Watches for authentication changes and rebuilds UI automatically
final class GoogleDriveAuthProvider
    extends $NotifierProvider<GoogleDriveAuth, bool> {
  /// Provider for Google Drive sign-in state
  /// Watches for authentication changes and rebuilds UI automatically
  const GoogleDriveAuthProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'googleDriveAuthProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$googleDriveAuthHash();

  @$internal
  @override
  GoogleDriveAuth create() => GoogleDriveAuth();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$googleDriveAuthHash() => r'db5b698cf89c7b3af5320e69d151cddc7135ea7f';

/// Provider for Google Drive sign-in state
/// Watches for authentication changes and rebuilds UI automatically

abstract class _$GoogleDriveAuth extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<bool, bool>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<bool, bool>, bool, Object?, Object?>;
    element.handleValue(ref, created);
  }
}

/// Convenience provider for sign-in status (bool)

@ProviderFor(isGoogleDriveSignedIn)
const isGoogleDriveSignedInProvider = IsGoogleDriveSignedInProvider._();

/// Convenience provider for sign-in status (bool)

final class IsGoogleDriveSignedInProvider
    extends $FunctionalProvider<bool, bool, bool> with $Provider<bool> {
  /// Convenience provider for sign-in status (bool)
  const IsGoogleDriveSignedInProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'isGoogleDriveSignedInProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$isGoogleDriveSignedInHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return isGoogleDriveSignedIn(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isGoogleDriveSignedInHash() =>
    r'e7360289e4a89b27a665c748e5508373e2042619';

/// Convenience provider for user email

@ProviderFor(googleDriveUserEmail)
const googleDriveUserEmailProvider = GoogleDriveUserEmailProvider._();

/// Convenience provider for user email

final class GoogleDriveUserEmailProvider
    extends $FunctionalProvider<String?, String?, String?>
    with $Provider<String?> {
  /// Convenience provider for user email
  const GoogleDriveUserEmailProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'googleDriveUserEmailProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$googleDriveUserEmailHash();

  @$internal
  @override
  $ProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String? create(Ref ref) {
    return googleDriveUserEmail(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$googleDriveUserEmailHash() =>
    r'c635c4c74b8dfae23688e76466e28e484a39764a';

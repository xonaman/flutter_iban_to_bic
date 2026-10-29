/// Determines the SWIFT BIC of an IBAN.
///
/// Currently supports AT, BE, DE, ES, FR, LT, LU and NL IBANs. Inspired by
/// [sigalor/iban-to-bic](https://github.com/sigalor/iban-to-bic).
library;

export 'src/bic.dart';
export 'src/bic_accuracy.dart';
export 'src/country_spec.dart';
export 'src/iban.dart' show InvalidIbanReason;
// Deprecated, kept for source compatibility until the next major release.
// ignore: deprecated_member_use_from_same_package
export 'src/asset_resolver.dart' show AssetJsonResolver;
export 'src/json_resolver.dart' show LazyJsonResolver;
export 'src/iban_to_bic.dart'
    show
        IbanToBic,
        ibanToBic,
        ibanToBicAsync,
        preloadIbanToBic,
        evictIbanToBic,
        sharedIbanToBic;
export 'src/resolver.dart';
export 'src/result.dart';

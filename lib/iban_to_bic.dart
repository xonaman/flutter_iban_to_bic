/// Determines the SWIFT BIC of an IBAN.
///
/// Currently supports AT, BE, DE, ES, FR, LT, LU and NL IBANs. Inspired by
/// [sigalor/iban-to-bic](https://github.com/sigalor/iban-to-bic).
library;

export 'src/bic.dart';
export 'src/country_spec.dart';
export 'src/iban.dart' show InvalidIbanReason;
export 'src/asset_resolver.dart' show AssetJsonResolver;
export 'src/iban_to_bic.dart'
    show
        IbanToBic,
        ibanToBic,
        ibanToBicAsync,
        preloadIbanToBic,
        sharedIbanToBic;
export 'src/resolver.dart';
export 'src/result.dart';

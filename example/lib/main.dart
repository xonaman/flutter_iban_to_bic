import 'package:flutter/material.dart';
import 'package:iban_to_bic/iban_to_bic.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Async variant needs no preload:
  final IbanLookupResult result =
      await ibanToBicAsync('DE64 5001 0517 9423 8144 35');

  switch (result) {
    case BicFound(:final Bic bic):
      debugPrint('BIC: ${bic.value}');
      debugPrint('Bank name: ${bic.bankShortName}');
      debugPrint('Postcode: ${bic.bankPostcode}');
      debugPrint('Location: ${bic.bankLocation}');
    case InvalidIban(:final String iban, :final InvalidIbanReason reason):
      debugPrint('Invalid IBAN ($reason): $iban');
    case UnsupportedCountry(:final String countryCode):
      debugPrint('Unsupported country: $countryCode');
    case UnknownBank(:final String countryCode, :final String bankCode):
      debugPrint('Unknown bank $bankCode in $countryCode');
  }
}

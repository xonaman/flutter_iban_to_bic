Determines the SWIFT BIC of an IBAN. Currently supports IBANs from the following countries:
Austria, Belgium, Germany, Lithuania, Luxembourg, Netherlands. Inspired by 
[sigalor/iban-to-bic](https://github.com/sigalor/iban-to-bic).

## Getting started

### Depend on it

Run this command:

```
flutter pub add iban_to_bic
```

### Import it

Now in your Dart code, you can use:

```dart
import 'package:iban_to_bic/iban_to_bic.dart';
```

## Example usage 

```dart
import 'package:flutter/material.dart';
import 'package:iban_to_bic/iban_to_bic.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final Bic bic = ibanToBic('DE64 5001 0517 9423 8144 35');
  print('BIC: ${bic.value}');                // result: INGDDEFFXXX
  print('Bank name: ${bic.bankShortName}');  // result: ING-DiBa
  print('Postcode: ${bic.bankPostcode}');    // result: 60628
  print('Location: ${bic.bankLocation}');    // result: Frankfurt am Main
}
```

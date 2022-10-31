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
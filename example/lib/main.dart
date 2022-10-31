import 'package:flutter/material.dart';
import 'package:iban_to_bic/iban_to_bic.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final Iban iban = ibanToBic('DE64 5001 0517 9423 8144 35');
  print('BIC: ${iban.bic}');                  // result: INGDDEFFXXX
  print('Bank name: ${iban.bankShortName}');  // result: ING-DiBa
  print('Postcode: ${iban.bankPostcode}');    // result: 60628
  print('Location: ${iban.bankLocation}');    // result: Frankfurt am Main
}
library iban_to_bic;

import 'dart:convert' show json;

import 'package:flutter/services.dart';
import 'package:iban/iban.dart' as ibantools;

Map<String, Map<String, dynamic>> _datasets = <String, Map<String, dynamic>>{};

Future<String> ibanToBic(String ibanString) async {
  ibanString = ibantools.electronicFormat(ibanString);
  if (!ibantools.isValid(ibanString)) {
    throw Exception('The given iban string $ibanString is invalid.');
  }
  final String countryCode = ibanString.substring(0, 2).toLowerCase();
  String? bankCode;
  switch (countryCode) {
    case 'at':
      bankCode = ibanString.substring(4, 9);
      break;
    case 'be':
      bankCode = ibanString.substring(4, 7);
      break;
    case 'de':
      bankCode = ibanString.substring(4, 12);
      break;
    case 'lu':
      bankCode = ibanString.substring(4, 7);
      break;
    case 'nl':
      bankCode = ibanString.substring(4, 8);
      break;
    default:
      throw Exception('Country code ${countryCode.toUpperCase()}'
          ' is not supported yet.');
  }
  if (!_datasets.containsKey(countryCode)) {
    _datasets[countryCode] = json.decode(await rootBundle
        .loadString('packages/iban_to_bic/res/datasets/$countryCode.json'));
  }
  return _datasets[countryCode]![bankCode];
}

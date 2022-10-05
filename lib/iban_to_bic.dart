library iban_to_bic;

import 'package:flutter/services.dart';
import 'package:iban/iban.dart' as ibantools;

Map<String, dynamic> _datasets = <String, dynamic>{};

Future<String> ibanToBic(String ibanString) async {
  ibanString = ibantools.electronicFormat(ibanString);
  if (!ibantools.isValid(ibanString)) {
    throw Exception('The given iban string $ibanString is invalid.');
  }
  final String countryCode = ibanString.substring(0, 2).toLowerCase();
  String? bankCode;
  switch (countryCode) {
    case 'at':
      bankCode = ibanString.substring(4, 5);
      break;
    case 'be':
      bankCode = ibanString.substring(4, 3);
      break;
    case 'de':
      bankCode = ibanString.substring(4, 8);
      break;
    case 'lu':
      bankCode = ibanString.substring(4, 3);
      break;
    case 'nl':
      bankCode = ibanString.substring(4, 4);
      break;
    default:
      throw Exception('Country code ${countryCode.toUpperCase()}'
          ' is not supported yet.');
  }
  if (!_datasets.containsKey(countryCode)) {
    _datasets[countryCode] =
        await rootBundle.loadString('res/datasets/$countryCode.json');
  }
  return _datasets[countryCode]![bankCode];
}

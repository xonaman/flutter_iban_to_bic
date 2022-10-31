part of iban_to_bic;

Iban ibanToBic(String ibanString) {
  ibanString = ibantools.electronicFormat(ibanString);
  if (!ibantools.isValid(ibanString)) {
    throw Exception('The given iban string $ibanString is invalid.');
  }
  final String countryCode = ibanString.substring(0, 2);
  switch (countryCode) {
    case 'AT':
      return _atBankCodes[ibanString.substring(4, 9)]!;
    case 'BE':
      return _beBankCodes[ibanString.substring(4, 7)]!;
    case 'DE':
      return _deBankCodes[ibanString.substring(4, 12)]!;
    case 'LT':
      return _ltBankCodes[ibanString.substring(4, 9)]!;
    case 'LU':
      return _luBankCodes[ibanString.substring(4, 7)]!;
    case 'NL':
      return _nlBankCodes[ibanString.substring(4, 8)]!;
    default:
      throw Exception('Country code $countryCode is not supported yet.');
  }
}

class Iban {
  final String bic;
  final String? bankName;
  final String? bankShortName;
  final String? bankAddress;
  final String? bankPostcode;
  final String? bankLocation;

  const Iban({
    required this.bic,
    this.bankName,
    this.bankShortName,
    this.bankAddress,
    this.bankPostcode,
    this.bankLocation,
  });

  @override
  String toString() {
    return 'Iban(${json.encode(<String, String?>{
          'bic': bic,
          'bankName': bankName,
          'bankShortName': bankShortName,
          'bankAddress': bankAddress,
          'bankPostcode': bankPostcode,
          'bankLocation': bankLocation,
        })})';
  }
}

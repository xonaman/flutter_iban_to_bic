part of iban_to_bic;

Bic ibanToBic(String ibanString) {
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

class Bic {
  final String value;
  final String bankName;
  final String bankShortName;
  final String? bankAddress;
  final String? bankPostcode;
  final String? bankLocation;

  const Bic({
    required this.value,
    required this.bankName,
    required this.bankShortName,
    this.bankAddress,
    this.bankPostcode,
    this.bankLocation,
  });

  @override
  String toString() {
    return 'Bic(${json.encode(<String, String?>{
          'bic': value,
          'bankName': bankName,
          'bankShortName': bankShortName,
          if (bankAddress != null) 'bankAddress': bankAddress,
          if (bankPostcode != null) 'bankPostcode': bankPostcode,
          if (bankLocation != null) 'bankLocation': bankLocation,
        })})';
  }
}

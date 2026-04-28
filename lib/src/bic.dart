import 'dart:convert' show json;

/// Details about a bank keyed by its national bank code inside an IBAN.
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

  Map<String, String?> toJson() => <String, String?>{
        'bic': value,
        'bankName': bankName,
        'bankShortName': bankShortName,
        if (bankAddress != null) 'bankAddress': bankAddress,
        if (bankPostcode != null) 'bankPostcode': bankPostcode,
        if (bankLocation != null) 'bankLocation': bankLocation,
      };

  @override
  String toString() => 'Bic(${json.encode(toJson())})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Bic &&
          other.value == value &&
          other.bankName == bankName &&
          other.bankShortName == bankShortName &&
          other.bankAddress == bankAddress &&
          other.bankPostcode == bankPostcode &&
          other.bankLocation == bankLocation;

  @override
  int get hashCode => Object.hash(
        value,
        bankName,
        bankShortName,
        bankAddress,
        bankPostcode,
        bankLocation,
      );
}

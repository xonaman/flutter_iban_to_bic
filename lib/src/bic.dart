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

  /// 4-letter institution code (chars 0-3 of a well-formed BIC).
  ///
  /// Returns an empty string when [value] is not a structurally valid BIC.
  String get institutionCode => value.length >= 4 ? value.substring(0, 4) : '';

  /// 2-letter ISO country code (chars 4-5 of a well-formed BIC).
  String get countryCode => value.length >= 6 ? value.substring(4, 6) : '';

  /// 2-char location code (chars 6-7 of a well-formed BIC).
  String get locationCode => value.length >= 8 ? value.substring(6, 8) : '';

  /// Optional 3-char branch code (chars 8-10), `null` for 8-char BICs.
  ///
  /// The conventional `'XXX'` branch (meaning "primary office") is returned
  /// verbatim — callers that want to collapse it to `null` can do so.
  String? get branchCode => value.length == 11 ? value.substring(8, 11) : null;

  /// `true` when the BIC appears structurally valid (8 or 11 uppercase
  /// alphanumerics). Does not verify the BIC is registered with SWIFT.
  bool get isWellFormed =>
      (value.length == 8 || value.length == 11) && _bicShape.hasMatch(value);

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

final RegExp _bicShape = RegExp(r'^[A-Z0-9]+$');

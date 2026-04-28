/// IBAN normalization and mod-97 validation.
///
/// Replaces the external `iban` package with ~30 lines of vetted logic so the
/// package has zero runtime dependencies beyond Flutter itself.
library;

final RegExp _whitespace = RegExp(r'\s+');
final RegExp _ibanShape = RegExp(r'^[A-Z]{2}\d{2}[A-Z0-9]+$');

/// Why an IBAN failed validation.
enum InvalidIbanReason {
  empty,
  tooShort,
  tooLong,
  badShape,
  badChecksum,
}

/// Outcome of validating an IBAN — either ok or a specific reason it failed.
sealed class IbanValidation {
  const IbanValidation();
}

final class IbanOk extends IbanValidation {
  const IbanOk();
}

final class IbanInvalid extends IbanValidation {
  final InvalidIbanReason reason;
  const IbanInvalid(this.reason);
}

/// Strips whitespace and upper-cases the input.
String normalizeIban(String raw) =>
    raw.replaceAll(_whitespace, '').toUpperCase();

/// Validates an already-[normalizeIban]-normalized IBAN per ISO 13616.
IbanValidation validateIban(String iban) {
  if (iban.isEmpty) return const IbanInvalid(InvalidIbanReason.empty);
  if (iban.length < 15) return const IbanInvalid(InvalidIbanReason.tooShort);
  if (iban.length > 34) return const IbanInvalid(InvalidIbanReason.tooLong);
  if (!_ibanShape.hasMatch(iban)) {
    return const IbanInvalid(InvalidIbanReason.badShape);
  }

  // Move first four chars to the end, then replace letters with digits
  // (A=10 … Z=35) and compute mod 97.
  final String rearranged = iban.substring(4) + iban.substring(0, 4);

  int remainder = 0;
  for (int i = 0; i < rearranged.length; i++) {
    final int code = rearranged.codeUnitAt(i);
    final int value;
    if (code >= 0x30 && code <= 0x39) {
      value = code - 0x30;
    } else if (code >= 0x41 && code <= 0x5A) {
      value = code - 0x41 + 10;
    } else {
      return const IbanInvalid(InvalidIbanReason.badShape);
    }
    // Fold one or two digits at a time to stay within int range.
    remainder = value < 10
        ? (remainder * 10 + value) % 97
        : (remainder * 100 + value) % 97;
  }
  return remainder == 1
      ? const IbanOk()
      : const IbanInvalid(InvalidIbanReason.badChecksum);
}

/// Shorthand: `true` when [validateIban] returns `IbanOk`.
bool isValidIban(String iban) => validateIban(iban) is IbanOk;

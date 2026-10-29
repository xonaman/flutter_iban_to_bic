/// How precisely the bank code inside an IBAN determines the account's BIC.
///
/// The lookup only ever reads the national bank code out of the IBAN. In
/// some countries that code alone fixes the BIC; in others it identifies
/// the institution, while the IBAN also carries a branch code the lookup
/// ignores and some institutions give branches their own BIC.
enum BicAccuracy {
  /// The bank code alone determines the BIC: the IBAN has no separate
  /// branch code, and the national directory assigns one BIC per bank
  /// code. The returned BIC is the one for the account, as long as the
  /// bundled dataset is current.
  ///
  /// Applies to AT, BE, DE, LT, LU and NL.
  exact,

  /// The bank code identifies the institution, but the account's own BIC
  /// may be a branch BIC of the same institution. The returned BIC is the
  /// institution's main BIC, which may not match the BIC printed on the
  /// account holder's statement.
  ///
  /// Applies to ES and FR, whose IBANs carry a branch code (oficina,
  /// code guichet) after the bank code. For example, every La Banque
  /// Postale IBAN starts with bank code 20041, but its accounts are held at
  /// regional centres with BICs such as `PSSTFRPPPAR` or `PSSTFRPPLIL`.
  institution,
}

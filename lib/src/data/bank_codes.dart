// Each country's dataset is its own deferred library: dart2js and dart2wasm
// split it into a separate file that's only downloaded the first time that
// country is looked up. On the VM and AOT, loadLibrary() completes at once.
import 'at.g.dart' deferred as at;
import 'be.g.dart' deferred as be;
import 'de.g.dart' deferred as de;
import 'es.g.dart' deferred as es;
import 'fr.g.dart' deferred as fr;
import 'lt.g.dart' deferred as lt;
import 'lu.g.dart' deferred as lu;
import 'nl.g.dart' deferred as nl;

/// Loads the bundled bank-code JSON for [countryCode] (upper case).
///
/// Throws [ArgumentError] for a country without a bundled dataset.
Future<String> loadBankCodesJson(String countryCode) async {
  switch (countryCode) {
    case 'AT':
      await at.loadLibrary();
      return at.bankCodesJson;
    case 'BE':
      await be.loadLibrary();
      return be.bankCodesJson;
    case 'DE':
      await de.loadLibrary();
      return de.bankCodesJson;
    case 'ES':
      await es.loadLibrary();
      return es.bankCodesJson;
    case 'FR':
      await fr.loadLibrary();
      return fr.bankCodesJson;
    case 'LT':
      await lt.loadLibrary();
      return lt.bankCodesJson;
    case 'LU':
      await lu.loadLibrary();
      return lu.bankCodesJson;
    case 'NL':
      await nl.loadLibrary();
      return nl.bankCodesJson;
  }
  throw ArgumentError.value(countryCode, 'countryCode', 'no bundled dataset');
}

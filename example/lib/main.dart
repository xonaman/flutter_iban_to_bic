import 'package:flutter/cupertino.dart';
import 'package:iban_to_bic/iban_to_bic.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print(await ibanToBic('DE64500105179423814435'));
  // result: INGDDEFFXXX
}

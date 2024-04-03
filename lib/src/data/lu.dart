part of iban_to_bic;

const Map<String, Bic> _luBankCodes = <String, Bic>{
  '001': Bic(
    value: 'BCEELULL',
    bankName: 'Banque et Caisse d\'Epargne de l\'Etat, Luxembourg (Spuerkeess)',
    bankShortName: 'Banque et Caisse d\'Epargne de l\'Etat, Luxembourg (Spuerkeess)',
  ),
  '002': Bic(
    value: 'BILLLULL',
    bankName: 'Banque Internationale à Luxembourg',
    bankShortName: 'Banque Internationale à Luxembourg',
  ),
  '003': Bic(
    value: 'BGLLLULL',
    bankName: 'BGL BNP Paribas',
    bankShortName: 'BGL BNP Paribas',
  ),
  '007': Bic(
    value: 'BSUILULL',
    bankName: 'CACEIS Bank Luxembourg Branch',
    bankShortName: 'CACEIS Bank Luxembourg Branch',
  ),
  '008': Bic(
    value: 'BLUXLULL',
    bankName: 'Banque de Luxembourg S.A.',
    bankShortName: 'Banque de Luxembourg S.A.',
  ),
  '009': Bic(
    value: 'CCRALULL',
    bankName: 'Banque Raiffeisen',
    bankShortName: 'Banque Raiffeisen',
  ),
  '010': Bic(
    value: 'FOTNLULL',
    bankName: 'Fortuna Banque s.c. ',
    bankShortName: 'Fortuna Banque s.c. ',
  ),
  '014': Bic(
    value: 'CELLLULL',
    bankName: 'ING Luxembourg',
    bankShortName: 'ING Luxembourg',
  ),
  '025': Bic(
    value: 'BMECLULL',
    bankName: 'SUCCURSALE LUXEMBOURGEOISE DE BANQUE POPULAIRE ALSACE LORRAINE CHAMPAGNE',
    bankShortName: 'SUCCURSALE LUXEMBOURGEOISE DE BANQUE POPULAIRE ALSACE LORRAINE CHAMPAGNE',
  ),
  '032': Bic(
    value: 'BAERLULU',
    bankName: 'Bank Julius Baer Europe S.A.',
    bankShortName: 'Bank Julius Baer Europe S.A.',
  ),
  '033': Bic(
    value: 'BSCHLULL',
    bankName: 'Banco Santander (Brasil) S.A., Luxembourg Branch',
    bankShortName: 'Banco Santander (Brasil) S.A., Luxembourg Branch',
  ),
  '034': Bic(
    value: 'CITILULX',
    bankName: 'Citibank Europe plc, Luxembourg Branch',
    bankShortName: 'Citibank Europe plc, Luxembourg Branch',
  ),
  '036': Bic(
    value: 'DEUTLULL',
    bankName: 'Deutsche Bank Luxembourg S.A.',
    bankShortName: 'Deutsche Bank Luxembourg S.A.',
  ),
  '038': Bic(
    value: 'DBSALULL',
    bankName: 'Union Bancaire Privée (Europe) S.A.',
    bankShortName: 'Union Bancaire Privée (Europe) S.A.',
  ),
  '051': Bic(
    value: 'NOLALULL',
    bankName: 'NORD/LB Luxembourg S.A. Covered Bond Bank',
    bankShortName: 'NORD/LB Luxembourg S.A. Covered Bond Bank',
  ),
  '058': Bic(
    value: 'WBWCLULL',
    bankName: 'European Depositary Bank S.A.',
    bankShortName: 'European Depositary Bank S.A.',
  ),
  '060': Bic(
    value: 'SGABLU2S',
    bankName: 'Société Générale Luxembourg',
    bankShortName: 'Société Générale Luxembourg',
  ),
  '061': Bic(
    value: 'SGABLULL',
    bankName: 'Société Générale Luxembourg',
    bankShortName: 'Société Générale Luxembourg',
  ),
  '062': Bic(
    value: 'HAUKLULL',
    bankName: 'Hauck Aufhäuser Lampe Privatbank AG, Niederlassung Luxemburg',
    bankShortName: 'Hauck Aufhäuser Lampe Privatbank AG, Niederlassung Luxemburg',
  ),
  '064': Bic(
    value: 'ESSELULL',
    bankName: 'SKANDINAVISKA ENSKILDA BANKEN AB, Luxembourg Branch',
    bankShortName: 'SKANDINAVISKA ENSKILDA BANKEN AB, Luxembourg Branch',
  ),
  '067': Bic(
    value: 'CHASLULX',
    bankName: 'J.P. Morgan SE, Luxembourg branch',
    bankShortName: 'J.P. Morgan SE, Luxembourg branch',
  ),
  '070': Bic(
    value: 'UBSWLULL',
    bankName: 'UBS EUROPE SE, Luxembourg Branch',
    bankShortName: 'UBS EUROPE SE, Luxembourg Branch',
  ),
  '077': Bic(
    value: 'MUGCLULL',
    bankName: 'Mitsubishi UFJ Investor Services & Banking (Luxembourg) S.A.',
    bankShortName: 'Mitsubishi UFJ Investor Services & Banking (Luxembourg) S.A.',
  ),
  '078': Bic(
    value: 'CRESLULL',
    bankName: 'Credit Suisse (Luxembourg) S.A.',
    bankShortName: 'Credit Suisse (Luxembourg) S.A.',
  ),
  '079': Bic(
    value: 'MUGCLULLBAS',
    bankName: 'Mitsubishi UFJ Investor Services & Banking (Luxembourg) S.A.',
    bankShortName: 'Mitsubishi UFJ Investor Services & Banking (Luxembourg) S.A.',
  ),
  '080': Bic(
    value: 'NIKOLULL',
    bankName: 'SMBC Nikko Bank (Luxembourg) S.A.',
    bankShortName: 'SMBC Nikko Bank (Luxembourg) S.A.',
  ),
  '083': Bic(
    value: 'DEGRLULL',
    bankName: 'Banque Degroof Petercam Luxembourg S.A.',
    bankShortName: 'Banque Degroof Petercam Luxembourg S.A.',
  ),
  '087': Bic(
    value: 'SEBKLULL',
    bankName: 'Intesa Sanpaolo Bank Luxembourg S.A.',
    bankShortName: 'Intesa Sanpaolo Bank Luxembourg S.A.',
  ),
  '104': Bic(
    value: 'SNCILUL1',
    bankName: 'Société Nationale de Crédit et d\'Investissement',
    bankShortName: 'Société Nationale de Crédit et d\'Investissement',
  ),
  '107': Bic(
    value: 'GENOLULL',
    bankName: 'DZ PRIVATBANK S.A.',
    bankShortName: 'DZ PRIVATBANK S.A.',
  ),
  '111': Bic(
    value: 'CCPLLULL',
    bankName: 'POST Group',
    bankShortName: 'POST Group',
  ),
  '116': Bic(
    value: 'BKCHLULL',
    bankName: 'Bank of China Limited Luxembourg Branch',
    bankShortName: 'Bank of China Limited Luxembourg Branch',
  ),
  '123': Bic(
    value: 'AGRILULA',
    bankName: 'CA Indosuez Wealth (Europe)',
    bankShortName: 'CA Indosuez Wealth (Europe)',
  ),
  '131': Bic(
    value: 'SPLBLUL1',
    bankName: 'State Street Bank Luxembourg S.A. (formerly Sanpaolo Bank S.A.)',
    bankShortName: 'State Street Bank Luxembourg S.A. (formerly Sanpaolo Bank S.A.)',
  ),
  '133': Bic(
    value: 'BBDELULL',
    bankName: 'Banco Bradesco Europa S.A.',
    bankShortName: 'Banco Bradesco Europa S.A.',
  ),
  '134': Bic(
    value: 'BPCPLULL',
    bankName: 'Banque de Commerce et de Placements S.A., Luxembourg Branch',
    bankShortName: 'Banque de Commerce et de Placements S.A., Luxembourg Branch',
  ),
  '135': Bic(
    value: 'DGZFLULI',
    bankName: 'DekaBank Deutsche Girozentrale, Succursale de Luxembourg',
    bankShortName: 'DekaBank Deutsche Girozentrale, Succursale de Luxembourg',
  ),
  '143': Bic(
    value: 'UBNLLULL',
    bankName: 'DNB Luxembourg S.A.',
    bankShortName: 'DNB Luxembourg S.A.',
  ),
  '146': Bic(
    value: 'STBCLULL',
    bankName: 'Sumitomo Mitsui Trust Bank (Luxembourg) S.A.',
    bankShortName: 'Sumitomo Mitsui Trust Bank (Luxembourg) S.A.',
  ),
  '147': Bic(
    value: 'BLICLULX',
    bankName: 'HSBC Private Bank (Luxembourg) S.A.',
    bankShortName: 'HSBC Private Bank (Luxembourg) S.A.',
  ),
  '148': Bic(
    value: 'BSAFLULL',
    bankName: 'Banque J. Safra Sarasin (Luxembourg) SA',
    bankShortName: 'Banque J. Safra Sarasin (Luxembourg) SA',
  ),
  '149': Bic(
    value: 'BNPALULS',
    bankName: 'BNP Paribas, Luxembourg Branch',
    bankShortName: 'BNP Paribas, Luxembourg Branch',
  ),
  '151': Bic(
    value: 'ERBKLULL',
    bankName: 'Eurobank Private Bank Luxembourg S.A.',
    bankShortName: 'Eurobank Private Bank Luxembourg S.A.',
  ),
  '158': Bic(
    value: 'UNCRLULL',
    bankName: 'UniCredit International Bank (Luxembourg) S.A.',
    bankShortName: 'UniCredit International Bank (Luxembourg) S.A.',
  ),
  '162': Bic(
    value: 'RBOSLULL',
    bankName: 'Royal Bank of Scotland International Limited, Luxembourg Branch (The)',
    bankShortName: 'Royal Bank of Scotland International Limited, Luxembourg Branch (The)',
  ),
  '164': Bic(
    value: 'HSHNLULB',
    bankName: 'Hamburg Commercial Bank AG Luxembourg Branch',
    bankShortName: 'Hamburg Commercial Bank AG Luxembourg Branch',
  ),
  '167': Bic(
    value: 'BBDALULX',
    bankName: 'HSBC Continental Europe, Luxembourg',
    bankShortName: 'HSBC Continental Europe, Luxembourg',
  ),
  '172': Bic(
    value: 'PRIBLULL',
    bankName: 'Edmond de Rothschild (Europe)',
    bankShortName: 'Edmond de Rothschild (Europe)',
  ),
  '177': Bic(
    value: 'BKBKLULL',
    bankName: 'Bankinter Luxembourg S.A.',
    bankShortName: 'Bankinter Luxembourg S.A.',
  ),
  '178': Bic(
    value: 'BBHCLULL',
    bankName: 'Brown Brothers Harriman (Luxembourg) S.C.A.',
    bankShortName: 'Brown Brothers Harriman (Luxembourg) S.C.A.',
  ),
  '181': Bic(
    value: 'MHTBLULL',
    bankName: 'Mizuho Trust & Banking (Luxembourg) S.A.',
    bankShortName: 'Mizuho Trust & Banking (Luxembourg) S.A.',
  ),
  '183': Bic(
    value: 'VPBVLULL',
    bankName: 'VP Bank (Luxembourg) SA',
    bankShortName: 'VP Bank (Luxembourg) SA',
  ),
  '193': Bic(
    value: 'CMCILUL1',
    bankName: 'Banque Transatlantique Luxembourg S.A.',
    bankShortName: 'Banque Transatlantique Luxembourg S.A.',
  ),
  '197': Bic(
    value: 'NATXLULL',
    bankName: 'Natixis Wealth Management Luxembourg',
    bankShortName: 'Natixis Wealth Management Luxembourg',
  ),
  '198': Bic(
    value: 'PICTLULX',
    bankName: 'Pictet & Cie (Europe) S.A.',
    bankShortName: 'Pictet & Cie (Europe) S.A.',
  ),
  '222': Bic(
    value: 'BKCHLULA',
    bankName: 'Bank of China (Europe) S.A.',
    bankShortName: 'Bank of China (Europe) S.A.',
  ),
  '229': Bic(
    value: 'HANDLULB',
    bankName: 'Svenska Handelsbanken AB (Publ), Luxembourg Branch',
    bankShortName: 'Svenska Handelsbanken AB (Publ), Luxembourg Branch',
  ),
  '250': Bic(
    value: 'CHASLULW',
    bankName: 'J.P. Morgan Bank Luxembourg S.A.',
    bankShortName: 'J.P. Morgan Bank Luxembourg S.A.',
  ),
  '259': Bic(
    value: 'DEUTLULB',
    bankName: 'Deutsche Bank AG, Filiale Luxemburg',
    bankShortName: 'Deutsche Bank AG, Filiale Luxemburg',
  ),
  '265': Bic(
    value: 'PBNKLULL',
    bankName: 'Deutsche Bank AG, Filiale Luxemburg (formerly Postbank Luxemburg)',
    bankShortName: 'Deutsche Bank AG, Filiale Luxemburg (formerly Postbank Luxemburg)',
  ),
  '281': Bic(
    value: 'FISPLU22',
    bankName: 'FIS Privatbank S.A.',
    bankShortName: 'FIS Privatbank S.A.',
  ),
  '284': Bic(
    value: 'HAVLLULL',
    bankName: 'Banque Havilland S.A.',
    bankShortName: 'Banque Havilland S.A.',
  ),
  '289': Bic(
    value: 'CEDELULL',
    bankName: 'Clearstream Banking S.A.',
    bankShortName: 'Clearstream Banking S.A.',
  ),
  '298': Bic(
    value: 'BPMOLULS',
    bankName: 'BPER Bank Luxembourg S.A.',
    bankShortName: 'BPER Bank Luxembourg S.A.',
  ),
  '301': Bic(
    value: 'EFGBLULX',
    bankName: 'EFG Bank (Luxembourg) S.A.',
    bankShortName: 'EFG Bank (Luxembourg) S.A.',
  ),
  '305': Bic(
    value: 'DELELULL',
    bankName: 'Delen Private Bank Luxembourg S.A.',
    bankShortName: 'Delen Private Bank Luxembourg S.A.',
  ),
  '308': Bic(
    value: 'FIBKLULL',
    bankName: 'Fideuram Bank (Luxembourg) S.A.',
    bankShortName: 'Fideuram Bank (Luxembourg) S.A.',
  ),
  '309': Bic(
    value: 'FIBKLULLFPB',
    bankName: 'Fideuram Bank (Luxembourg) S.A.',
    bankShortName: 'Fideuram Bank (Luxembourg) S.A.',
  ),
  '316': Bic(
    value: 'ICBKLULL',
    bankName: 'Industrial and Commercial Bank of China Ltd., Luxembourg Branch',
    bankShortName: 'Industrial and Commercial Bank of China Ltd., Luxembourg Branch',
  ),
  '318': Bic(
    value: 'HAVLLULL',
    bankName: 'Banque Havilland S.A.',
    bankShortName: 'Banque Havilland S.A.',
  ),
  '324': Bic(
    value: 'SWQBLULL',
    bankName: 'Swissquote Bank Europe S.A.',
    bankShortName: 'Swissquote Bank Europe S.A.',
  ),
  '328': Bic(
    value: 'PARBLULL',
    bankName: 'BNP Paribas, Luxembourg Branch',
    bankShortName: 'BNP Paribas, Luxembourg Branch',
  ),
  '338': Bic(
    value: 'CRESLULX',
    bankName: 'Credit Suisse AG, Luxembourg Branch',
    bankShortName: 'Credit Suisse AG, Luxembourg Branch',
  ),
  '340': Bic(
    value: 'IRVTLULX',
    bankName: 'The Bank of New York Mellon S.A./N.V., Luxembourg Branch',
    bankShortName: 'The Bank of New York Mellon S.A./N.V., Luxembourg Branch',
  ),
  '341': Bic(
    value: 'FETALULL',
    bankName: 'RBC Investor Services Bank S.A.',
    bankShortName: 'RBC Investor Services Bank S.A.',
  ),
  '342': Bic(
    value: 'MEOILUL1',
    bankName: 'Mediobanca International (Luxembourg) S.A.',
    bankShortName: 'Mediobanca International (Luxembourg) S.A.',
  ),
  '343': Bic(
    value: 'EFGBLULX',
    bankName: 'EFG Bank (Luxembourg) S.A.',
    bankShortName: 'EFG Bank (Luxembourg) S.A.',
  ),
  '344': Bic(
    value: 'ADVZLULL',
    bankName: 'Advanzia Bank S.A.',
    bankShortName: 'Advanzia Bank S.A.',
  ),
  '348': Bic(
    value: 'ICBKLULU',
    bankName: 'Industrial and Commercial Bank of China (Europe) S.A.',
    bankShortName: 'Industrial and Commercial Bank of China (Europe) S.A.',
  ),
  '349': Bic(
    value: 'CITCLULL',
    bankName: 'Citco Bank Nederland N.V., Luxembourg Branch',
    bankShortName: 'Citco Bank Nederland N.V., Luxembourg Branch',
  ),
  '350': Bic(
    value: 'CBPXLULL',
    bankName: 'Intesa Sanpaolo Wealth Management',
    bankShortName: 'Intesa Sanpaolo Wealth Management',
  ),
  '351': Bic(
    value: 'PPLXLULL',
    bankName: 'PayPal (Europe) S.à r.l. et Cie, S.C.A.',
    bankShortName: 'PayPal (Europe) S.à r.l. et Cie, S.C.A.',
  ),
  '358': Bic(
    value: 'SBOSLULX',
    bankName: 'State Street Bank International GmbH, Zweigniederlassung Luxemburg',
    bankShortName: 'State Street Bank International GmbH, Zweigniederlassung Luxemburg',
  ),
  '359': Bic(
    value: 'KEYTLULL',
    bankName: 'Keytrade Bank Luxembourg S.A.',
    bankShortName: 'Keytrade Bank Luxembourg S.A.',
  ),
  '360': Bic(
    value: 'BACALULL',
    bankName: 'Andbank Luxembourg',
    bankShortName: 'Andbank Luxembourg',
  ),
  '361': Bic(
    value: 'BBPPLULL',
    bankName: 'Banque de Patrimoines Privés',
    bankShortName: 'Banque de Patrimoines Privés',
  ),
  '364': Bic(
    value: 'LOCYLULL',
    bankName: 'Lombard Odier (Europe) S.A.',
    bankShortName: 'Lombard Odier (Europe) S.A.',
  ),
  '365': Bic(
    value: 'BESCLULL',
    bankName: 'Novo Banco S.A., Succursale de Luxembourg',
    bankShortName: 'Novo Banco S.A., Succursale de Luxembourg',
  ),
  '368': Bic(
    value: 'BMARLU2M',
    bankName: 'Banca March, S.A., Luxembourg Branch',
    bankShortName: 'Banca March, S.A., Luxembourg Branch',
  ),
  '371': Bic(
    value: 'SAFRLULLCCY',
    bankName: 'Banco Safra S.A., Luxembourg Branch',
    bankShortName: 'Banco Safra S.A., Luxembourg Branch',
  ),
  '372': Bic(
    value: 'BEMOLULL',
    bankName: 'BEMO Europe - Banque Privée',
    bankShortName: 'BEMO Europe - Banque Privée',
  ),
  '374': Bic(
    value: 'HSBCLULL',
    bankName: 'HSBC Continental Europe, Luxembourg',
    bankShortName: 'HSBC Continental Europe, Luxembourg',
  ),
  '375': Bic(
    value: 'PCBCLULL',
    bankName: 'China Construction Bank (Europe) S.A.',
    bankShortName: 'China Construction Bank (Europe) S.A.',
  ),
  '377': Bic(
    value: 'PCBCLULX',
    bankName: 'China Construction Bank Corporation, Luxembourg Branch',
    bankShortName: 'China Construction Bank Corporation, Luxembourg Branch',
  ),
  '379': Bic(
    value: 'GAZPLULL',
    bankName: 'Bank GPB International S.A.',
    bankShortName: 'Bank GPB International S.A.',
  ),
  '381': Bic(
    value: 'MIRALULL',
    bankName: 'Mirabaud & Cie (Europe) S.A.',
    bankShortName: 'Mirabaud & Cie (Europe) S.A.',
  ),
  '386': Bic(
    value: 'ALLFLULL',
    bankName: 'Allfunds Bank International S.A.U.',
    bankShortName: 'Allfunds Bank International S.A.U.',
  ),
  '390': Bic(
    value: 'COMMLULL',
    bankName: 'Bank of Communications (Luxembourg) S.A.',
    bankShortName: 'Bank of Communications (Luxembourg) S.A.',
  ),
  '391': Bic(
    value: 'CMBCLULL',
    bankName: 'China Merchants Bank Co., Ltd., Luxembourg Branch',
    bankShortName: 'China Merchants Bank Co., Ltd., Luxembourg Branch',
  ),
  '392': Bic(
    value: 'ABOCLULL',
    bankName: 'Agricultural Bank of China (Luxembourg) S.A.',
    bankShortName: 'Agricultural Bank of China (Luxembourg) S.A.',
  ),
  '393': Bic(
    value: 'ABOCLULB',
    bankName: 'Agricultural Bank of China, Luxembourg Branch',
    bankShortName: 'Agricultural Bank of China, Luxembourg Branch',
  ),
  '400': Bic(
    value: 'RRBALULL',
    bankName: 'RiverBank S.A.',
    bankShortName: 'RiverBank S.A.',
  ),
  '404': Bic(
    value: 'HYVELULL',
    bankName: 'UniCredit Bank AG Luxembourg Branch',
    bankShortName: 'UniCredit Bank AG Luxembourg Branch',
  ),
  '406': Bic(
    value: 'CNORLULX',
    bankName: 'Northern Trust Global Services SE',
    bankShortName: 'Northern Trust Global Services SE',
  ),
  '408': Bic(
    value: 'BCIRLULL',
    bankName: 'Banking Circle S.A.',
    bankShortName: 'Banking Circle S.A.',
  ),
  '409': Bic(
    value: 'BARCLULL',
    bankName: 'Barclays Bank Ireland plc, Luxembourg Branch',
    bankShortName: 'Barclays Bank Ireland plc, Luxembourg Branch',
  ),
  '410': Bic(
    value: 'ESSELU22',
    bankName: 'Skandinaviska Enskilda Banken AB Luxembourg branch',
    bankShortName: 'Skandinaviska Enskilda Banken AB Luxembourg branch',
  ),
  '411': Bic(
    value: 'CAIXLULL',
    bankName: 'CaixaBank Wealth Management Luxembourg S.A.',
    bankShortName: 'CaixaBank Wealth Management Luxembourg S.A.',
  ),
  '413': Bic(
    value: 'CRBALULL',
    bankName: 'Alpha Bank S.A., Luxembourg Branch',
    bankShortName: 'Alpha Bank S.A., Luxembourg Branch',
  ),
  '414': Bic(
    value: 'USBKLU2L',
    bankName: 'Elavon Financial Services DAC - Luxembourg Branch',
    bankShortName: 'Elavon Financial Services DAC - Luxembourg Branch',
  ),
  '415': Bic(
    value: 'GOLDLULL',
    bankName: 'GoldmanSachs Bank Europe SE, Luxembourg Branch',
    bankShortName: 'GoldmanSachs Bank Europe SE, Luxembourg Branch',
  ),
  '421': Bic(
    value: 'CHDBLU22',
    bankName: 'DONNER & REUSCHEL Aktiengesellschaft',
    bankShortName: 'DONNER & REUSCHEL Aktiengesellschaft',
  ),
  '606': Bic(
    value: 'OLKILUL1',
    bankName: 'Olky Payment Service Provider S.A.',
    bankShortName: 'Olky Payment Service Provider S.A.',
  ),
  '619': Bic(
    value: 'SOXALULL',
    bankName: 'Sogexia S.A.',
    bankShortName: 'Sogexia S.A.',
  ),
  '625': Bic(
    value: 'PANXLUL2',
    bankName: 'UnifiedPost Payments S.A. - Luxembourg Branch',
    bankShortName: 'UnifiedPost Payments S.A. - Luxembourg Branch',
  ),
  '627': Bic(
    value: 'EBPBLUL2',
    bankName: 'Ebury Partners Belgium - succursale luxembourgeoise',
    bankShortName: 'Ebury Partners Belgium - succursale luxembourgeoise',
  ),
  '699': Bic(
    value: 'RBOSLULL',
    bankName: 'Royal Bank of Scotland International Limited, Luxembourg Branch (The)',
    bankShortName: 'Royal Bank of Scotland International Limited, Luxembourg Branch (The)',
  ),
  '700': Bic(
    value: 'EWUBLUL2',
    bankName: 'East-West United Bank S.A.',
    bankShortName: 'East-West United Bank S.A.',
  ),
  '701': Bic(
    value: 'RAPSLUL1',
    bankName: 'Rakuten Europe Bank S.A.',
    bankShortName: 'Rakuten Europe Bank S.A.',
  ),
  '705': Bic(
    value: 'KBLXLULL',
    bankName: 'Quintet Private Bank (Europe) S.A.',
    bankShortName: 'Quintet Private Bank (Europe) S.A.',
  ),
  '711': Bic(
    value: 'DOCKLU22',
    bankName: 'Dock Financial S.A.',
    bankShortName: 'Dock Financial S.A.',
  ),
  '713': Bic(
    value: 'IBNXLULM',
    bankName: 'COMO DL S.A.',
    bankShortName: 'COMO DL S.A.',
  ),
  '751': Bic(
    value: 'PPLXLUL2',
    bankName: 'PayPal (Europe) S.à r.l. et Cie, S.C.A.',
    bankShortName: 'PayPal (Europe) S.à r.l. et Cie, S.C.A.',
  ),
  '777': Bic(
    value: 'MUGCLULX',
    bankName: 'Mitsubishi UFJ Investor Services & Banking (Luxembourg) S.A.',
    bankShortName: 'Mitsubishi UFJ Investor Services & Banking (Luxembourg) S.A.',
  ),
  '778': Bic(
    value: 'BOFALULL',
    bankName: 'Bank of America Europe DAC, Luxembourg Branch',
    bankShortName: 'Bank of America Europe DAC, Luxembourg Branch',
  ),
  '802': Bic(
    value: 'SATYLUL1SRV',
    bankName: 'Satispay Europe S.A.',
    bankShortName: 'Satispay Europe S.A.',
  ),
  '805': Bic(
    value: 'MAGYLUL1',
    bankName: 'MANGOPAY S.A.',
    bankShortName: 'MANGOPAY S.A.',
  ),
  '807': Bic(
    value: 'SSWILUL1',
    bankName: 'SnapSwap International S.A.',
    bankShortName: 'SnapSwap International S.A.',
  ),
  '810': Bic(
    value: 'SATYLUL1XXX',
    bankName: 'Satispay Europe S.A.',
    bankShortName: 'Satispay Europe S.A.',
  ),
  '811': Bic(
    value: 'DOCKLUL2',
    bankName: 'Dock Financial S.A.',
    bankShortName: 'Dock Financial S.A.',
  ),
  '813': Bic(
    value: 'VPAYLUL2',
    bankName: 'Viva Payment Services Single Members S.A. - Luxembourg Branch',
    bankShortName: 'Viva Payment Services Single Members S.A. - Luxembourg Branch',
  ),
  '815': Bic(
    value: 'VVIDLUL2',
    bankName: 'Vivid Money S.A. (formerly Joompay Europe S.A.)',
    bankShortName: 'Vivid Money S.A. (formerly Joompay Europe S.A.)',
  ),
  '816': Bic(
    value: 'MOLULU22',
    bankName: '3S Money (Luxembourg) S.A.',
    bankShortName: '3S Money (Luxembourg) S.A.',
  ),
  '998': Bic(
    value: 'BEILLULL',
    bankName: 'Banque Européenne d\'Investissement',
    bankShortName: 'Banque Européenne d\'Investissement',
  ),
  '999': Bic(
    value: 'BCLXLULL',
    bankName: 'Banque Centrale du Luxembourg',
    bankShortName: 'Banque Centrale du Luxembourg',
  ),
};

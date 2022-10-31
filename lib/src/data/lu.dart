part of iban_to_bic;

const Map<String, Bic> _luBankCodes = <String, Bic>{
  '001': Bic(
    value: 'BCEE LU LL',
    bankName: 'Banque et Caisse d’Epargne de l’Etat, Luxembourg (Spuerkeess)',
    bankShortName:
        'Banque et Caisse d’Epargne de l’Etat, Luxembourg (Spuerkeess)',
  ),
  '002': Bic(
    value: 'BILL LU LL',
    bankName: 'Banque Internationale à Luxembourg S.A.',
    bankShortName: 'Banque Internationale à Luxembourg S.A.',
  ),
  '003': Bic(
    value: 'BGLL LU LL',
    bankName: 'BGL BNP Paribas S.A.',
    bankShortName: 'BGL BNP Paribas S.A.',
  ),
  '007': Bic(
    value: 'BSUI LU LL',
    bankName: 'CACEIS Bank Luxembourg Branch',
    bankShortName: 'CACEIS Bank Luxembourg Branch',
  ),
  '008': Bic(
    value: 'BLUX LU LL',
    bankName: 'Banque de Luxembourg',
    bankShortName: 'Banque de Luxembourg',
  ),
  '009': Bic(
    value: 'CCRA LU LL',
    bankName: 'Banque Raiffeisen',
    bankShortName: 'Banque Raiffeisen',
  ),
  '010': Bic(
    value: 'FOTN LU LL',
    bankName: 'Fortuna Banque s.c.',
    bankShortName: 'Fortuna Banque s.c.',
  ),
  '014': Bic(
    value: 'CELL LU LL',
    bankName: 'ING Luxembourg',
    bankShortName: 'ING Luxembourg',
  ),
  '025': Bic(
    value: 'BMEC LU LL',
    bankName: 'Banque BCP S.A.',
    bankShortName: 'Banque BCP S.A.',
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
    value: 'CITI LU LX',
    bankName: 'Citibank Europe plc, Luxembourg Branch',
    bankShortName: 'Citibank Europe plc, Luxembourg Branch',
  ),
  '036': Bic(
    value: 'DEUT LU LL',
    bankName: 'Deutsche Bank Luxembourg S.A.',
    bankShortName: 'Deutsche Bank Luxembourg S.A.',
  ),
  '038': Bic(
    value: 'DBSA LU LL',
    bankName: 'Union Bancaire Privée (Europe) S.A.',
    bankShortName: 'Union Bancaire Privée (Europe) S.A.',
  ),
  '051': Bic(
    value: 'NOLA LU LL',
    bankName: 'NORD/LB Luxembourg S.A. Covered Bond Bank',
    bankShortName: 'NORD/LB Luxembourg S.A. Covered Bond Bank',
  ),
  '058': Bic(
    value: 'WBWC LU LL',
    bankName: 'European Depositary Bank S.A.',
    bankShortName: 'European Depositary Bank S.A.',
  ),
  '060': Bic(
    value: 'SGABLU2S',
    bankName: 'Société Générale Luxembourg',
    bankShortName: 'Société Générale Luxembourg',
  ),
  '061': Bic(
    value: 'SGAB LU LL',
    bankName: 'Société Générale Luxembourg',
    bankShortName: 'Société Générale Luxembourg',
  ),
  '062': Bic(
    value: 'HAUK LU LL',
    bankName: 'Hauck & Aufhäuser Privatbankiers AG, Niederlassung Luxemburg',
    bankShortName:
        'Hauck & Aufhäuser Privatbankiers AG, Niederlassung Luxemburg',
  ),
  '064': Bic(
    value: 'ESSE LU LL',
    bankName: 'Skandinaviska Enskilda Banken AB (publ), Luxembourg Branch',
    bankShortName: 'Skandinaviska Enskilda Banken AB (publ), Luxembourg Branch',
  ),
  '067': Bic(
    value: 'CHAS LU LX',
    bankName: 'J.P. Morgan Bank Luxembourg S.A.',
    bankShortName: 'J.P. Morgan Bank Luxembourg S.A.',
  ),
  '070': Bic(
    value: 'UBSW LU LL',
    bankName: 'UBS EUROPE SE, Luxembourg Branch',
    bankShortName: 'UBS EUROPE SE, Luxembourg Branch',
  ),
  '077': Bic(
    value: 'MUGC LU LL',
    bankName: 'Mitsubishi UFJ Investor Services & Banking (Luxembourg) S.A.',
    bankShortName:
        'Mitsubishi UFJ Investor Services & Banking (Luxembourg) S.A.',
  ),
  '078': Bic(
    value: 'CRES LU LL',
    bankName: 'Credit Suisse (Luxembourg) S.A.',
    bankShortName: 'Credit Suisse (Luxembourg) S.A.',
  ),
  '079': Bic(
    value: 'MUGCLULLBAS',
    bankName: 'Mitsubishi UFJ Investor Services & Banking (Luxembourg) S.A.',
    bankShortName:
        'Mitsubishi UFJ Investor Services & Banking (Luxembourg) S.A.',
  ),
  '080': Bic(
    value: 'NIKO LU LL',
    bankName: 'SMBC Nikko Bank (Luxembourg) S.A.',
    bankShortName: 'SMBC Nikko Bank (Luxembourg) S.A.',
  ),
  '082': Bic(
    value: 'EWUB LU LL',
    bankName: 'East-West United Bank S.A.',
    bankShortName: 'East-West United Bank S.A.',
  ),
  '083': Bic(
    value: 'DEGR LU LL',
    bankName: 'Banque Degroof Petercam Luxembourg S.A.',
    bankShortName: 'Banque Degroof Petercam Luxembourg S.A.',
  ),
  '087': Bic(
    value: 'SEBK LU LL',
    bankName: 'Intesa Sanpaolo Bank Luxembourg S.A.',
    bankShortName: 'Intesa Sanpaolo Bank Luxembourg S.A.',
  ),
  '093': Bic(
    value: 'DABA LU LL',
    bankName: 'Danske Bank International S.A.',
    bankShortName: 'Danske Bank International S.A.',
  ),
  '097': Bic(
    value: 'HSHN LU LL',
    bankName: 'HCOB Securities S.A.',
    bankShortName: 'HCOB Securities S.A.',
  ),
  '104': Bic(
    value: 'SNCI LU L1',
    bankName: 'Société Nationale de Crédit et d’Investissement',
    bankShortName: 'Société Nationale de Crédit et d’Investissement',
  ),
  '107': Bic(
    value: 'GENO LU LL',
    bankName: 'DZ PRIVATBANK S.A.',
    bankShortName: 'DZ PRIVATBANK S.A.',
  ),
  '111': Bic(
    value: 'CCPL LU LL',
    bankName: 'POST Group',
    bankShortName: 'POST Group',
  ),
  '116': Bic(
    value: 'BKCH LU LL',
    bankName: 'Bank of China Limited Luxembourg Branch',
    bankShortName: 'Bank of China Limited Luxembourg Branch',
  ),
  '123': Bic(
    value: 'AGRI LU LA',
    bankName: 'CA Indosuez Wealth (Europe)',
    bankShortName: 'CA Indosuez Wealth (Europe)',
  ),
  '131': Bic(
    value: 'SPLB LU L1',
    bankName: 'State Street Bank Luxembourg S.A. (formerly Sanpaolo Bank S.A.)',
    bankShortName:
        'State Street Bank Luxembourg S.A. (formerly Sanpaolo Bank S.A.)',
  ),
  '133': Bic(
    value: 'BBDE LU LL',
    bankName: 'Banco Bradesco Europa S.A.',
    bankShortName: 'Banco Bradesco Europa S.A.',
  ),
  '134': Bic(
    value: 'BPCP LU LL',
    bankName: 'Banque de Commerce et de Placements S.A., Luxembourg Branch',
    bankShortName:
        'Banque de Commerce et de Placements S.A., Luxembourg Branch',
  ),
  '135': Bic(
    value: 'DGZFLULI',
    bankName: 'DekaBank Deutsche Girozentrale, Succursale de Luxembourg',
    bankShortName: 'DekaBank Deutsche Girozentrale, Succursale de Luxembourg',
  ),
  '143': Bic(
    value: 'UBNL LU LL',
    bankName: 'DNB Luxembourg S.A.',
    bankShortName: 'DNB Luxembourg S.A.',
  ),
  '144': Bic(
    value: 'IKBD LU L1',
    bankName: 'IKB Deutsche Industriebank AG, Filiale Luxemburg',
    bankShortName: 'IKB Deutsche Industriebank AG, Filiale Luxemburg',
  ),
  '146': Bic(
    value: 'STBC LU LL',
    bankName: 'Sumitomo Mitsui Trust Bank (Luxembourg) S.A.',
    bankShortName: 'Sumitomo Mitsui Trust Bank (Luxembourg) S.A.',
  ),
  '147': Bic(
    value: 'BLIC LU LX',
    bankName: 'HSBC Private Bank (Luxembourg) S.A.',
    bankShortName: 'HSBC Private Bank (Luxembourg) S.A.',
  ),
  '148': Bic(
    value: 'BSAF LU LL',
    bankName: 'Banque J. Safra Sarasin (Luxembourg) SA',
    bankShortName: 'Banque J. Safra Sarasin (Luxembourg) SA',
  ),
  '149': Bic(
    value: 'BNPA LU LS',
    bankName: 'BNP Paribas, Luxembourg Branch',
    bankShortName: 'BNP Paribas, Luxembourg Branch',
  ),
  '151': Bic(
    value: 'ERBK LU LL',
    bankName: 'Eurobank Private Bank Luxembourg S.A.',
    bankShortName: 'Eurobank Private Bank Luxembourg S.A.',
  ),
  '158': Bic(
    value: 'UNCR LU LL',
    bankName: 'UniCredit International Bank (Luxembourg) S.A.',
    bankShortName: 'UniCredit International Bank (Luxembourg) S.A.',
  ),
  '162': Bic(
    value: 'RBOSLULL',
    bankName:
        'Royal Bank of Scotland International Limited, Luxembourg Branch (The)',
    bankShortName:
        'Royal Bank of Scotland International Limited, Luxembourg Branch (The)',
  ),
  '164': Bic(
    value: 'HSHN LU LB',
    bankName: 'Hamburg Commercial Bank AG Luxembourg Branch',
    bankShortName: 'Hamburg Commercial Bank AG Luxembourg Branch',
  ),
  '167': Bic(
    value: 'BBDA LU LX',
    bankName: 'HSBC Continental Europe, Luxembourg',
    bankShortName: 'HSBC Continental Europe, Luxembourg',
  ),
  '172': Bic(
    value: 'PRIB LU LL',
    bankName: 'Edmond de Rothschild (Europe)',
    bankShortName: 'Edmond de Rothschild (Europe)',
  ),
  '177': Bic(
    value: 'BKBK LU LL',
    bankName: 'Bankinter Luxembourg S.A.',
    bankShortName: 'Bankinter Luxembourg S.A.',
  ),
  '178': Bic(
    value: 'BBHC LU LL',
    bankName: 'Brown Brothers Harriman (Luxembourg) S.C.A.',
    bankShortName: 'Brown Brothers Harriman (Luxembourg) S.C.A.',
  ),
  '181': Bic(
    value: 'MHTB LU LL',
    bankName: 'Mizuho Trust & Banking (Luxembourg) S.A.',
    bankShortName: 'Mizuho Trust & Banking (Luxembourg) S.A.',
  ),
  '183': Bic(
    value: 'VPBV LU LL',
    bankName: 'VP Bank (Luxembourg) SA',
    bankShortName: 'VP Bank (Luxembourg) SA',
  ),
  '193': Bic(
    value: 'CMCI LU L1',
    bankName: 'Banque Transatlantique Luxembourg S.A.',
    bankShortName: 'Banque Transatlantique Luxembourg S.A.',
  ),
  '197': Bic(
    value: 'NATX LU LL',
    bankName: 'Natixis Wealth Management Luxembourg',
    bankShortName: 'Natixis Wealth Management Luxembourg',
  ),
  '198': Bic(
    value: 'PICT LU LX',
    bankName: 'Pictet & Cie (Europe) S.A.',
    bankShortName: 'Pictet & Cie (Europe) S.A.',
  ),
  '204': Bic(
    value: 'NBLX LU LL',
    bankName: 'Nomura Bank (Luxembourg) S.A.',
    bankShortName: 'Nomura Bank (Luxembourg) S.A.',
  ),
  '222': Bic(
    value: 'BKCHLULA',
    bankName: 'Bank of China (Luxembourg) S.A.',
    bankShortName: 'Bank of China (Luxembourg) S.A.',
  ),
  '229': Bic(
    value: 'HAND LU LB',
    bankName: 'Svenska Handelsbanken AB (Publ), Luxembourg Branch',
    bankShortName: 'Svenska Handelsbanken AB (Publ), Luxembourg Branch',
  ),
  '250': Bic(
    value: 'CHASLULW',
    bankName: 'J.P. Morgan Bank Luxembourg S.A.',
    bankShortName: 'J.P. Morgan Bank Luxembourg S.A.',
  ),
  '259': Bic(
    value: 'DEUT LU LB',
    bankName: 'Deutsche Bank AG, Filiale Luxemburg',
    bankShortName: 'Deutsche Bank AG, Filiale Luxemburg',
  ),
  '265': Bic(
    value: 'PBNKLULL',
    bankName:
        'Deutsche Bank AG, Filiale Luxemburg (formerly Postbank Luxemburg)',
    bankShortName:
        'Deutsche Bank AG, Filiale Luxemburg (formerly Postbank Luxemburg)',
  ),
  '281': Bic(
    value: 'FISPLU22',
    bankName: 'FIS Privatbank - die Unternehmerbank',
    bankShortName: 'FIS Privatbank - die Unternehmerbank',
  ),
  '284': Bic(
    value: 'HAVLLULL',
    bankName: 'Banque Havilland S.A.',
    bankShortName: 'Banque Havilland S.A.',
  ),
  '289': Bic(
    value: 'CEDE LU LL',
    bankName: 'Clearstream Banking',
    bankShortName: 'Clearstream Banking',
  ),
  '298': Bic(
    value: 'BPMO LU LS',
    bankName: 'BPER Bank Luxembourg S.A.',
    bankShortName: 'BPER Bank Luxembourg S.A.',
  ),
  '301': Bic(
    value: 'EFGBLULX',
    bankName: 'EFG Bank (Luxembourg) S.A.',
    bankShortName: 'EFG Bank (Luxembourg) S.A.',
  ),
  '305': Bic(
    value: 'DELE LU LL',
    bankName: 'Delen Private Bank Luxembourg S.A.',
    bankShortName: 'Delen Private Bank Luxembourg S.A.',
  ),
  '308': Bic(
    value: 'FIBK LU LL',
    bankName: 'Fideuram Bank (Luxembourg) S.A.',
    bankShortName: 'Fideuram Bank (Luxembourg) S.A.',
  ),
  '309': Bic(
    value: 'FIBKLULLFPB',
    bankName: 'Fideuram Bank (Luxembourg) S.A.',
    bankShortName: 'Fideuram Bank (Luxembourg) S.A.',
  ),
  '316': Bic(
    value: 'ICBK LU LL',
    bankName: 'Industrial and Commercial Bank of China Ltd., Luxembourg Branch',
    bankShortName:
        'Industrial and Commercial Bank of China Ltd., Luxembourg Branch',
  ),
  '317': Bic(
    value: 'JODE LU L1',
    bankName: 'John Deere Bank S.A.',
    bankShortName: 'John Deere Bank S.A.',
  ),
  '318': Bic(
    value: 'HAVL LU LL',
    bankName: 'Banque Havilland S.A.',
    bankShortName: 'Banque Havilland S.A.',
  ),
  '324': Bic(
    value: 'SWQBLULL',
    bankName: 'Swissquote Bank Europe S.A.',
    bankShortName: 'Swissquote Bank Europe S.A.',
  ),
  '328': Bic(
    value: 'PARB LU LL',
    bankName: 'BNP Paribas, Luxembourg Branch',
    bankShortName: 'BNP Paribas, Luxembourg Branch',
  ),
  '338': Bic(
    value: 'CRES LU LX',
    bankName: 'Credit Suisse AG, Luxembourg Branch',
    bankShortName: 'Credit Suisse AG, Luxembourg Branch',
  ),
  '340': Bic(
    value: 'IRVTLULX',
    bankName: 'The Bank of New York Mellon S.A./N.V., Luxembourg Branch',
    bankShortName: 'The Bank of New York Mellon S.A./N.V., Luxembourg Branch',
  ),
  '341': Bic(
    value: 'FETA LU LL',
    bankName: 'RBC Investor Services Bank S.A.',
    bankShortName: 'RBC Investor Services Bank S.A.',
  ),
  '342': Bic(
    value: 'MEOI LU L1',
    bankName: 'Mediobanca International (Luxembourg) S.A.',
    bankShortName: 'Mediobanca International (Luxembourg) S.A.',
  ),
  '343': Bic(
    value: 'EFGB LU LX',
    bankName: 'EFG Bank (Luxembourg) S.A.',
    bankShortName: 'EFG Bank (Luxembourg) S.A.',
  ),
  '344': Bic(
    value: 'ADVZ LU LL',
    bankName: 'Advanzia Bank S.A.',
    bankShortName: 'Advanzia Bank S.A.',
  ),
  '347': Bic(
    value: 'COBA LU LU',
    bankName: 'Commerzbank AG, Filiale Luxemburg',
    bankShortName: 'Commerzbank AG, Filiale Luxemburg',
  ),
  '348': Bic(
    value: 'ICBK LU LU',
    bankName: 'Industrial and Commercial Bank of China (Europe) S.A.',
    bankShortName: 'Industrial and Commercial Bank of China (Europe) S.A.',
  ),
  '349': Bic(
    value: 'CITC LU LL',
    bankName: 'Citco Bank Nederland N.V., Luxembourg Branch',
    bankShortName: 'Citco Bank Nederland N.V., Luxembourg Branch',
  ),
  '350': Bic(
    value: 'CBPX LU LL',
    bankName: 'Compagnie de Banque Privée Quilvest S.A.',
    bankShortName: 'Compagnie de Banque Privée Quilvest S.A.',
  ),
  '351': Bic(
    value: 'PPLX LU LL',
    bankName: 'PayPal (Europe) S.à r.l. et Cie, S.C.A.',
    bankShortName: 'PayPal (Europe) S.à r.l. et Cie, S.C.A.',
  ),
  '358': Bic(
    value: 'SBOS LU LX',
    bankName:
        'State Street Bank International GmbH, Zweigniederlassung Luxemburg',
    bankShortName:
        'State Street Bank International GmbH, Zweigniederlassung Luxemburg',
  ),
  '359': Bic(
    value: 'KEYTLULL',
    bankName: 'Keytrade Bank Luxembourg S.A.',
    bankShortName: 'Keytrade Bank Luxembourg S.A.',
  ),
  '360': Bic(
    value: 'BACA LU LL',
    bankName: 'Andbank Luxembourg',
    bankShortName: 'Andbank Luxembourg',
  ),
  '361': Bic(
    value: 'BBPP LU LL',
    bankName: 'Banque de Patrimoines Privés',
    bankShortName: 'Banque de Patrimoines Privés',
  ),
  '364': Bic(
    value: 'LOCY LU LL',
    bankName: 'Lombard Odier (Europe) S.A.',
    bankShortName: 'Lombard Odier (Europe) S.A.',
  ),
  '365': Bic(
    value: 'BESC LU LL',
    bankName: 'Novo Banco S.A., Succursale de Luxembourg',
    bankShortName: 'Novo Banco S.A., Succursale de Luxembourg',
  ),
  '368': Bic(
    value: 'BMAR LU 2M',
    bankName: 'Banca March, S.A., Luxembourg Branch',
    bankShortName: 'Banca March, S.A., Luxembourg Branch',
  ),
  '371': Bic(
    value: 'SAFRLULLCCY',
    bankName: 'Banco Safra S.A., Luxembourg Branch',
    bankShortName: 'Banco Safra S.A., Luxembourg Branch',
  ),
  '372': Bic(
    value: 'BEMO LU LL',
    bankName: 'BEMO Europe - Banque Privée',
    bankShortName: 'BEMO Europe - Banque Privée',
  ),
  '374': Bic(
    value: 'HSBCLULL',
    bankName: 'HSBC Continental Europe, Luxembourg',
    bankShortName: 'HSBC Continental Europe, Luxembourg',
  ),
  '375': Bic(
    value: 'PCBC LU LL',
    bankName: 'China Construction Bank (Europe) S.A.',
    bankShortName: 'China Construction Bank (Europe) S.A.',
  ),
  '377': Bic(
    value: 'PCBC LU LX',
    bankName: 'China Construction Bank Corporation, Luxembourg Branch',
    bankShortName: 'China Construction Bank Corporation, Luxembourg Branch',
  ),
  '379': Bic(
    value: 'GAZP LU LL',
    bankName: 'Bank GPB International S.A.',
    bankShortName: 'Bank GPB International S.A.',
  ),
  '381': Bic(
    value: 'MIRA LU LL',
    bankName: 'Mirabaud & Cie (Europe) S.A.',
    bankShortName: 'Mirabaud & Cie (Europe) S.A.',
  ),
  '386': Bic(
    value: 'ALLF LU LL',
    bankName: 'Allfunds Bank International S.A.',
    bankShortName: 'Allfunds Bank International S.A.',
  ),
  '390': Bic(
    value: 'COMM LU LL',
    bankName: 'Bank of Communications (Luxembourg) S.A.',
    bankShortName: 'Bank of Communications (Luxembourg) S.A.',
  ),
  '391': Bic(
    value: 'CMBC LU LL',
    bankName: 'China Merchants Bank Co., Ltd., Luxembourg Branch',
    bankShortName: 'China Merchants Bank Co., Ltd., Luxembourg Branch',
  ),
  '392': Bic(
    value: 'ABOC LU LL',
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
  '606': Bic(
    value: 'OLKILUL1',
    bankName: 'Olky Payment Service Provider S.A.',
    bankShortName: 'Olky Payment Service Provider S.A.',
  ),
  '613': Bic(
    value: 'ONPXLULM',
    bankName: 'iBAN-X S.A.',
    bankShortName: 'iBAN-X S.A.',
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
  '699': Bic(
    value: 'RBOSLULL',
    bankName:
        'Royal Bank of Scotland International Limited, Luxembourg Branch (The)',
    bankShortName:
        'Royal Bank of Scotland International Limited, Luxembourg Branch (The)',
  ),
  '700': Bic(
    value: 'EWUB LU L2',
    bankName: 'East-West United Bank S.A.',
    bankShortName: 'East-West United Bank S.A.',
  ),
  '701': Bic(
    value: 'RAPSLUL1',
    bankName: 'Rakuten Europe Bank S.A.',
    bankShortName: 'Rakuten Europe Bank S.A.',
  ),
  '705': Bic(
    value: 'KBLX LU LL',
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
    bankName: 'iBAN-X S.A.',
    bankShortName: 'iBAN-X S.A.',
  ),
  '777': Bic(
    value: 'MUGCLULX',
    bankName: 'Mitsubishi UFJ Investor Services & Banking (Luxembourg) S.A.',
    bankShortName:
        'Mitsubishi UFJ Investor Services & Banking (Luxembourg) S.A.',
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
    bankName: 'Viva Payment Services S.A. - Luxembourg Branch',
    bankShortName: 'Viva Payment Services S.A. - Luxembourg Branch',
  ),
  '815': Bic(
    value: 'JOEULUL2',
    bankName: 'Joompay Europe S.A.',
    bankShortName: 'Joompay Europe S.A.',
  ),
  '998': Bic(
    value: 'BEIL LU LL',
    bankName: 'Banque européenne d’investissement',
    bankShortName: 'Banque européenne d’investissement',
  ),
  '999': Bic(
    value: 'BCLX LU LL',
    bankName: 'Banque centrale du Luxembourg',
    bankShortName: 'Banque centrale du Luxembourg',
  ),
};

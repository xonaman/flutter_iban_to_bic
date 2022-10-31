part of iban_to_bic;

const Map<String, Iban> _luBankCodes = <String, Iban>{
  '001': Iban(
    bic: 'BCEE LU LL',
    bankName: 'Banque et Caisse d’Epargne de l’Etat, Luxembourg (Spuerkeess)',
    bankShortName:
        'Banque et Caisse d’Epargne de l’Etat, Luxembourg (Spuerkeess)',
  ),
  '002': Iban(
    bic: 'BILL LU LL',
    bankName: 'Banque Internationale à Luxembourg S.A.',
    bankShortName: 'Banque Internationale à Luxembourg S.A.',
  ),
  '003': Iban(
    bic: 'BGLL LU LL',
    bankName: 'BGL BNP Paribas S.A.',
    bankShortName: 'BGL BNP Paribas S.A.',
  ),
  '007': Iban(
    bic: 'BSUI LU LL',
    bankName: 'CACEIS Bank Luxembourg Branch',
    bankShortName: 'CACEIS Bank Luxembourg Branch',
  ),
  '008': Iban(
    bic: 'BLUX LU LL',
    bankName: 'Banque de Luxembourg',
    bankShortName: 'Banque de Luxembourg',
  ),
  '009': Iban(
    bic: 'CCRA LU LL',
    bankName: 'Banque Raiffeisen',
    bankShortName: 'Banque Raiffeisen',
  ),
  '010': Iban(
    bic: 'FOTN LU LL',
    bankName: 'Fortuna Banque s.c.',
    bankShortName: 'Fortuna Banque s.c.',
  ),
  '014': Iban(
    bic: 'CELL LU LL',
    bankName: 'ING Luxembourg',
    bankShortName: 'ING Luxembourg',
  ),
  '025': Iban(
    bic: 'BMEC LU LL',
    bankName: 'Banque BCP S.A.',
    bankShortName: 'Banque BCP S.A.',
  ),
  '032': Iban(
    bic: 'BAERLULU',
    bankName: 'Bank Julius Baer Europe S.A.',
    bankShortName: 'Bank Julius Baer Europe S.A.',
  ),
  '033': Iban(
    bic: 'BSCHLULL',
    bankName: 'Banco Santander (Brasil) S.A., Luxembourg Branch',
    bankShortName: 'Banco Santander (Brasil) S.A., Luxembourg Branch',
  ),
  '034': Iban(
    bic: 'CITI LU LX',
    bankName: 'Citibank Europe plc, Luxembourg Branch',
    bankShortName: 'Citibank Europe plc, Luxembourg Branch',
  ),
  '036': Iban(
    bic: 'DEUT LU LL',
    bankName: 'Deutsche Bank Luxembourg S.A.',
    bankShortName: 'Deutsche Bank Luxembourg S.A.',
  ),
  '038': Iban(
    bic: 'DBSA LU LL',
    bankName: 'Union Bancaire Privée (Europe) S.A.',
    bankShortName: 'Union Bancaire Privée (Europe) S.A.',
  ),
  '051': Iban(
    bic: 'NOLA LU LL',
    bankName: 'NORD/LB Luxembourg S.A. Covered Bond Bank',
    bankShortName: 'NORD/LB Luxembourg S.A. Covered Bond Bank',
  ),
  '058': Iban(
    bic: 'WBWC LU LL',
    bankName: 'European Depositary Bank S.A.',
    bankShortName: 'European Depositary Bank S.A.',
  ),
  '060': Iban(
    bic: 'SGABLU2S',
    bankName: 'Société Générale Luxembourg',
    bankShortName: 'Société Générale Luxembourg',
  ),
  '061': Iban(
    bic: 'SGAB LU LL',
    bankName: 'Société Générale Luxembourg',
    bankShortName: 'Société Générale Luxembourg',
  ),
  '062': Iban(
    bic: 'HAUK LU LL',
    bankName: 'Hauck & Aufhäuser Privatbankiers AG, Niederlassung Luxemburg',
    bankShortName:
        'Hauck & Aufhäuser Privatbankiers AG, Niederlassung Luxemburg',
  ),
  '064': Iban(
    bic: 'ESSE LU LL',
    bankName: 'Skandinaviska Enskilda Banken AB (publ), Luxembourg Branch',
    bankShortName: 'Skandinaviska Enskilda Banken AB (publ), Luxembourg Branch',
  ),
  '067': Iban(
    bic: 'CHAS LU LX',
    bankName: 'J.P. Morgan Bank Luxembourg S.A.',
    bankShortName: 'J.P. Morgan Bank Luxembourg S.A.',
  ),
  '070': Iban(
    bic: 'UBSW LU LL',
    bankName: 'UBS EUROPE SE, Luxembourg Branch',
    bankShortName: 'UBS EUROPE SE, Luxembourg Branch',
  ),
  '077': Iban(
    bic: 'MUGC LU LL',
    bankName: 'Mitsubishi UFJ Investor Services & Banking (Luxembourg) S.A.',
    bankShortName:
        'Mitsubishi UFJ Investor Services & Banking (Luxembourg) S.A.',
  ),
  '078': Iban(
    bic: 'CRES LU LL',
    bankName: 'Credit Suisse (Luxembourg) S.A.',
    bankShortName: 'Credit Suisse (Luxembourg) S.A.',
  ),
  '079': Iban(
    bic: 'MUGCLULLBAS',
    bankName: 'Mitsubishi UFJ Investor Services & Banking (Luxembourg) S.A.',
    bankShortName:
        'Mitsubishi UFJ Investor Services & Banking (Luxembourg) S.A.',
  ),
  '080': Iban(
    bic: 'NIKO LU LL',
    bankName: 'SMBC Nikko Bank (Luxembourg) S.A.',
    bankShortName: 'SMBC Nikko Bank (Luxembourg) S.A.',
  ),
  '082': Iban(
    bic: 'EWUB LU LL',
    bankName: 'East-West United Bank S.A.',
    bankShortName: 'East-West United Bank S.A.',
  ),
  '083': Iban(
    bic: 'DEGR LU LL',
    bankName: 'Banque Degroof Petercam Luxembourg S.A.',
    bankShortName: 'Banque Degroof Petercam Luxembourg S.A.',
  ),
  '087': Iban(
    bic: 'SEBK LU LL',
    bankName: 'Intesa Sanpaolo Bank Luxembourg S.A.',
    bankShortName: 'Intesa Sanpaolo Bank Luxembourg S.A.',
  ),
  '093': Iban(
    bic: 'DABA LU LL',
    bankName: 'Danske Bank International S.A.',
    bankShortName: 'Danske Bank International S.A.',
  ),
  '097': Iban(
    bic: 'HSHN LU LL',
    bankName: 'HCOB Securities S.A.',
    bankShortName: 'HCOB Securities S.A.',
  ),
  '104': Iban(
    bic: 'SNCI LU L1',
    bankName: 'Société Nationale de Crédit et d’Investissement',
    bankShortName: 'Société Nationale de Crédit et d’Investissement',
  ),
  '107': Iban(
    bic: 'GENO LU LL',
    bankName: 'DZ PRIVATBANK S.A.',
    bankShortName: 'DZ PRIVATBANK S.A.',
  ),
  '111': Iban(
    bic: 'CCPL LU LL',
    bankName: 'POST Group',
    bankShortName: 'POST Group',
  ),
  '116': Iban(
    bic: 'BKCH LU LL',
    bankName: 'Bank of China Limited Luxembourg Branch',
    bankShortName: 'Bank of China Limited Luxembourg Branch',
  ),
  '123': Iban(
    bic: 'AGRI LU LA',
    bankName: 'CA Indosuez Wealth (Europe)',
    bankShortName: 'CA Indosuez Wealth (Europe)',
  ),
  '131': Iban(
    bic: 'SPLB LU L1',
    bankName: 'State Street Bank Luxembourg S.A. (formerly Sanpaolo Bank S.A.)',
    bankShortName:
        'State Street Bank Luxembourg S.A. (formerly Sanpaolo Bank S.A.)',
  ),
  '133': Iban(
    bic: 'BBDE LU LL',
    bankName: 'Banco Bradesco Europa S.A.',
    bankShortName: 'Banco Bradesco Europa S.A.',
  ),
  '134': Iban(
    bic: 'BPCP LU LL',
    bankName: 'Banque de Commerce et de Placements S.A., Luxembourg Branch',
    bankShortName:
        'Banque de Commerce et de Placements S.A., Luxembourg Branch',
  ),
  '135': Iban(
    bic: 'DGZFLULI',
    bankName: 'DekaBank Deutsche Girozentrale, Succursale de Luxembourg',
    bankShortName: 'DekaBank Deutsche Girozentrale, Succursale de Luxembourg',
  ),
  '143': Iban(
    bic: 'UBNL LU LL',
    bankName: 'DNB Luxembourg S.A.',
    bankShortName: 'DNB Luxembourg S.A.',
  ),
  '144': Iban(
    bic: 'IKBD LU L1',
    bankName: 'IKB Deutsche Industriebank AG, Filiale Luxemburg',
    bankShortName: 'IKB Deutsche Industriebank AG, Filiale Luxemburg',
  ),
  '146': Iban(
    bic: 'STBC LU LL',
    bankName: 'Sumitomo Mitsui Trust Bank (Luxembourg) S.A.',
    bankShortName: 'Sumitomo Mitsui Trust Bank (Luxembourg) S.A.',
  ),
  '147': Iban(
    bic: 'BLIC LU LX',
    bankName: 'HSBC Private Bank (Luxembourg) S.A.',
    bankShortName: 'HSBC Private Bank (Luxembourg) S.A.',
  ),
  '148': Iban(
    bic: 'BSAF LU LL',
    bankName: 'Banque J. Safra Sarasin (Luxembourg) SA',
    bankShortName: 'Banque J. Safra Sarasin (Luxembourg) SA',
  ),
  '149': Iban(
    bic: 'BNPA LU LS',
    bankName: 'BNP Paribas, Luxembourg Branch',
    bankShortName: 'BNP Paribas, Luxembourg Branch',
  ),
  '151': Iban(
    bic: 'ERBK LU LL',
    bankName: 'Eurobank Private Bank Luxembourg S.A.',
    bankShortName: 'Eurobank Private Bank Luxembourg S.A.',
  ),
  '158': Iban(
    bic: 'UNCR LU LL',
    bankName: 'UniCredit International Bank (Luxembourg) S.A.',
    bankShortName: 'UniCredit International Bank (Luxembourg) S.A.',
  ),
  '162': Iban(
    bic: 'RBOSLULL',
    bankName:
        'Royal Bank of Scotland International Limited, Luxembourg Branch (The)',
    bankShortName:
        'Royal Bank of Scotland International Limited, Luxembourg Branch (The)',
  ),
  '164': Iban(
    bic: 'HSHN LU LB',
    bankName: 'Hamburg Commercial Bank AG Luxembourg Branch',
    bankShortName: 'Hamburg Commercial Bank AG Luxembourg Branch',
  ),
  '167': Iban(
    bic: 'BBDA LU LX',
    bankName: 'HSBC Continental Europe, Luxembourg',
    bankShortName: 'HSBC Continental Europe, Luxembourg',
  ),
  '172': Iban(
    bic: 'PRIB LU LL',
    bankName: 'Edmond de Rothschild (Europe)',
    bankShortName: 'Edmond de Rothschild (Europe)',
  ),
  '177': Iban(
    bic: 'BKBK LU LL',
    bankName: 'Bankinter Luxembourg S.A.',
    bankShortName: 'Bankinter Luxembourg S.A.',
  ),
  '178': Iban(
    bic: 'BBHC LU LL',
    bankName: 'Brown Brothers Harriman (Luxembourg) S.C.A.',
    bankShortName: 'Brown Brothers Harriman (Luxembourg) S.C.A.',
  ),
  '181': Iban(
    bic: 'MHTB LU LL',
    bankName: 'Mizuho Trust & Banking (Luxembourg) S.A.',
    bankShortName: 'Mizuho Trust & Banking (Luxembourg) S.A.',
  ),
  '183': Iban(
    bic: 'VPBV LU LL',
    bankName: 'VP Bank (Luxembourg) SA',
    bankShortName: 'VP Bank (Luxembourg) SA',
  ),
  '193': Iban(
    bic: 'CMCI LU L1',
    bankName: 'Banque Transatlantique Luxembourg S.A.',
    bankShortName: 'Banque Transatlantique Luxembourg S.A.',
  ),
  '197': Iban(
    bic: 'NATX LU LL',
    bankName: 'Natixis Wealth Management Luxembourg',
    bankShortName: 'Natixis Wealth Management Luxembourg',
  ),
  '198': Iban(
    bic: 'PICT LU LX',
    bankName: 'Pictet & Cie (Europe) S.A.',
    bankShortName: 'Pictet & Cie (Europe) S.A.',
  ),
  '204': Iban(
    bic: 'NBLX LU LL',
    bankName: 'Nomura Bank (Luxembourg) S.A.',
    bankShortName: 'Nomura Bank (Luxembourg) S.A.',
  ),
  '222': Iban(
    bic: 'BKCHLULA',
    bankName: 'Bank of China (Luxembourg) S.A.',
    bankShortName: 'Bank of China (Luxembourg) S.A.',
  ),
  '229': Iban(
    bic: 'HAND LU LB',
    bankName: 'Svenska Handelsbanken AB (Publ), Luxembourg Branch',
    bankShortName: 'Svenska Handelsbanken AB (Publ), Luxembourg Branch',
  ),
  '250': Iban(
    bic: 'CHASLULW',
    bankName: 'J.P. Morgan Bank Luxembourg S.A.',
    bankShortName: 'J.P. Morgan Bank Luxembourg S.A.',
  ),
  '259': Iban(
    bic: 'DEUT LU LB',
    bankName: 'Deutsche Bank AG, Filiale Luxemburg',
    bankShortName: 'Deutsche Bank AG, Filiale Luxemburg',
  ),
  '265': Iban(
    bic: 'PBNKLULL',
    bankName:
        'Deutsche Bank AG, Filiale Luxemburg (formerly Postbank Luxemburg)',
    bankShortName:
        'Deutsche Bank AG, Filiale Luxemburg (formerly Postbank Luxemburg)',
  ),
  '281': Iban(
    bic: 'FISPLU22',
    bankName: 'FIS Privatbank - die Unternehmerbank',
    bankShortName: 'FIS Privatbank - die Unternehmerbank',
  ),
  '284': Iban(
    bic: 'HAVLLULL',
    bankName: 'Banque Havilland S.A.',
    bankShortName: 'Banque Havilland S.A.',
  ),
  '289': Iban(
    bic: 'CEDE LU LL',
    bankName: 'Clearstream Banking',
    bankShortName: 'Clearstream Banking',
  ),
  '298': Iban(
    bic: 'BPMO LU LS',
    bankName: 'BPER Bank Luxembourg S.A.',
    bankShortName: 'BPER Bank Luxembourg S.A.',
  ),
  '301': Iban(
    bic: 'EFGBLULX',
    bankName: 'EFG Bank (Luxembourg) S.A.',
    bankShortName: 'EFG Bank (Luxembourg) S.A.',
  ),
  '305': Iban(
    bic: 'DELE LU LL',
    bankName: 'Delen Private Bank Luxembourg S.A.',
    bankShortName: 'Delen Private Bank Luxembourg S.A.',
  ),
  '308': Iban(
    bic: 'FIBK LU LL',
    bankName: 'Fideuram Bank (Luxembourg) S.A.',
    bankShortName: 'Fideuram Bank (Luxembourg) S.A.',
  ),
  '309': Iban(
    bic: 'FIBKLULLFPB',
    bankName: 'Fideuram Bank (Luxembourg) S.A.',
    bankShortName: 'Fideuram Bank (Luxembourg) S.A.',
  ),
  '316': Iban(
    bic: 'ICBK LU LL',
    bankName: 'Industrial and Commercial Bank of China Ltd., Luxembourg Branch',
    bankShortName:
        'Industrial and Commercial Bank of China Ltd., Luxembourg Branch',
  ),
  '317': Iban(
    bic: 'JODE LU L1',
    bankName: 'John Deere Bank S.A.',
    bankShortName: 'John Deere Bank S.A.',
  ),
  '318': Iban(
    bic: 'HAVL LU LL',
    bankName: 'Banque Havilland S.A.',
    bankShortName: 'Banque Havilland S.A.',
  ),
  '324': Iban(
    bic: 'SWQBLULL',
    bankName: 'Swissquote Bank Europe S.A.',
    bankShortName: 'Swissquote Bank Europe S.A.',
  ),
  '328': Iban(
    bic: 'PARB LU LL',
    bankName: 'BNP Paribas, Luxembourg Branch',
    bankShortName: 'BNP Paribas, Luxembourg Branch',
  ),
  '338': Iban(
    bic: 'CRES LU LX',
    bankName: 'Credit Suisse AG, Luxembourg Branch',
    bankShortName: 'Credit Suisse AG, Luxembourg Branch',
  ),
  '340': Iban(
    bic: 'IRVTLULX',
    bankName: 'The Bank of New York Mellon S.A./N.V., Luxembourg Branch',
    bankShortName: 'The Bank of New York Mellon S.A./N.V., Luxembourg Branch',
  ),
  '341': Iban(
    bic: 'FETA LU LL',
    bankName: 'RBC Investor Services Bank S.A.',
    bankShortName: 'RBC Investor Services Bank S.A.',
  ),
  '342': Iban(
    bic: 'MEOI LU L1',
    bankName: 'Mediobanca International (Luxembourg) S.A.',
    bankShortName: 'Mediobanca International (Luxembourg) S.A.',
  ),
  '343': Iban(
    bic: 'EFGB LU LX',
    bankName: 'EFG Bank (Luxembourg) S.A.',
    bankShortName: 'EFG Bank (Luxembourg) S.A.',
  ),
  '344': Iban(
    bic: 'ADVZ LU LL',
    bankName: 'Advanzia Bank S.A.',
    bankShortName: 'Advanzia Bank S.A.',
  ),
  '347': Iban(
    bic: 'COBA LU LU',
    bankName: 'Commerzbank AG, Filiale Luxemburg',
    bankShortName: 'Commerzbank AG, Filiale Luxemburg',
  ),
  '348': Iban(
    bic: 'ICBK LU LU',
    bankName: 'Industrial and Commercial Bank of China (Europe) S.A.',
    bankShortName: 'Industrial and Commercial Bank of China (Europe) S.A.',
  ),
  '349': Iban(
    bic: 'CITC LU LL',
    bankName: 'Citco Bank Nederland N.V., Luxembourg Branch',
    bankShortName: 'Citco Bank Nederland N.V., Luxembourg Branch',
  ),
  '350': Iban(
    bic: 'CBPX LU LL',
    bankName: 'Compagnie de Banque Privée Quilvest S.A.',
    bankShortName: 'Compagnie de Banque Privée Quilvest S.A.',
  ),
  '351': Iban(
    bic: 'PPLX LU LL',
    bankName: 'PayPal (Europe) S.à r.l. et Cie, S.C.A.',
    bankShortName: 'PayPal (Europe) S.à r.l. et Cie, S.C.A.',
  ),
  '358': Iban(
    bic: 'SBOS LU LX',
    bankName:
        'State Street Bank International GmbH, Zweigniederlassung Luxemburg',
    bankShortName:
        'State Street Bank International GmbH, Zweigniederlassung Luxemburg',
  ),
  '359': Iban(
    bic: 'KEYTLULL',
    bankName: 'Keytrade Bank Luxembourg S.A.',
    bankShortName: 'Keytrade Bank Luxembourg S.A.',
  ),
  '360': Iban(
    bic: 'BACA LU LL',
    bankName: 'Andbank Luxembourg',
    bankShortName: 'Andbank Luxembourg',
  ),
  '361': Iban(
    bic: 'BBPP LU LL',
    bankName: 'Banque de Patrimoines Privés',
    bankShortName: 'Banque de Patrimoines Privés',
  ),
  '364': Iban(
    bic: 'LOCY LU LL',
    bankName: 'Lombard Odier (Europe) S.A.',
    bankShortName: 'Lombard Odier (Europe) S.A.',
  ),
  '365': Iban(
    bic: 'BESC LU LL',
    bankName: 'Novo Banco S.A., Succursale de Luxembourg',
    bankShortName: 'Novo Banco S.A., Succursale de Luxembourg',
  ),
  '368': Iban(
    bic: 'BMAR LU 2M',
    bankName: 'Banca March, S.A., Luxembourg Branch',
    bankShortName: 'Banca March, S.A., Luxembourg Branch',
  ),
  '371': Iban(
    bic: 'SAFRLULLCCY',
    bankName: 'Banco Safra S.A., Luxembourg Branch',
    bankShortName: 'Banco Safra S.A., Luxembourg Branch',
  ),
  '372': Iban(
    bic: 'BEMO LU LL',
    bankName: 'BEMO Europe - Banque Privée',
    bankShortName: 'BEMO Europe - Banque Privée',
  ),
  '374': Iban(
    bic: 'HSBCLULL',
    bankName: 'HSBC Continental Europe, Luxembourg',
    bankShortName: 'HSBC Continental Europe, Luxembourg',
  ),
  '375': Iban(
    bic: 'PCBC LU LL',
    bankName: 'China Construction Bank (Europe) S.A.',
    bankShortName: 'China Construction Bank (Europe) S.A.',
  ),
  '377': Iban(
    bic: 'PCBC LU LX',
    bankName: 'China Construction Bank Corporation, Luxembourg Branch',
    bankShortName: 'China Construction Bank Corporation, Luxembourg Branch',
  ),
  '379': Iban(
    bic: 'GAZP LU LL',
    bankName: 'Bank GPB International S.A.',
    bankShortName: 'Bank GPB International S.A.',
  ),
  '381': Iban(
    bic: 'MIRA LU LL',
    bankName: 'Mirabaud & Cie (Europe) S.A.',
    bankShortName: 'Mirabaud & Cie (Europe) S.A.',
  ),
  '386': Iban(
    bic: 'ALLF LU LL',
    bankName: 'Allfunds Bank International S.A.',
    bankShortName: 'Allfunds Bank International S.A.',
  ),
  '390': Iban(
    bic: 'COMM LU LL',
    bankName: 'Bank of Communications (Luxembourg) S.A.',
    bankShortName: 'Bank of Communications (Luxembourg) S.A.',
  ),
  '391': Iban(
    bic: 'CMBC LU LL',
    bankName: 'China Merchants Bank Co., Ltd., Luxembourg Branch',
    bankShortName: 'China Merchants Bank Co., Ltd., Luxembourg Branch',
  ),
  '392': Iban(
    bic: 'ABOC LU LL',
    bankName: 'Agricultural Bank of China (Luxembourg) S.A.',
    bankShortName: 'Agricultural Bank of China (Luxembourg) S.A.',
  ),
  '393': Iban(
    bic: 'ABOCLULB',
    bankName: 'Agricultural Bank of China, Luxembourg Branch',
    bankShortName: 'Agricultural Bank of China, Luxembourg Branch',
  ),
  '400': Iban(
    bic: 'RRBALULL',
    bankName: 'RiverBank S.A.',
    bankShortName: 'RiverBank S.A.',
  ),
  '404': Iban(
    bic: 'HYVELULL',
    bankName: 'UniCredit Bank AG Luxembourg Branch',
    bankShortName: 'UniCredit Bank AG Luxembourg Branch',
  ),
  '408': Iban(
    bic: 'BCIRLULL',
    bankName: 'Banking Circle S.A.',
    bankShortName: 'Banking Circle S.A.',
  ),
  '409': Iban(
    bic: 'BARCLULL',
    bankName: 'Barclays Bank Ireland plc, Luxembourg Branch',
    bankShortName: 'Barclays Bank Ireland plc, Luxembourg Branch',
  ),
  '411': Iban(
    bic: 'CAIXLULL',
    bankName: 'CaixaBank Wealth Management Luxembourg S.A.',
    bankShortName: 'CaixaBank Wealth Management Luxembourg S.A.',
  ),
  '413': Iban(
    bic: 'CRBALULL',
    bankName: 'Alpha Bank S.A., Luxembourg Branch',
    bankShortName: 'Alpha Bank S.A., Luxembourg Branch',
  ),
  '414': Iban(
    bic: 'USBKLU2L',
    bankName: 'Elavon Financial Services DAC - Luxembourg Branch',
    bankShortName: 'Elavon Financial Services DAC - Luxembourg Branch',
  ),
  '606': Iban(
    bic: 'OLKILUL1',
    bankName: 'Olky Payment Service Provider S.A.',
    bankShortName: 'Olky Payment Service Provider S.A.',
  ),
  '613': Iban(
    bic: 'ONPXLULM',
    bankName: 'iBAN-X S.A.',
    bankShortName: 'iBAN-X S.A.',
  ),
  '619': Iban(
    bic: 'SOXALULL',
    bankName: 'Sogexia S.A.',
    bankShortName: 'Sogexia S.A.',
  ),
  '625': Iban(
    bic: 'PANXLUL2',
    bankName: 'UnifiedPost Payments S.A. - Luxembourg Branch',
    bankShortName: 'UnifiedPost Payments S.A. - Luxembourg Branch',
  ),
  '699': Iban(
    bic: 'RBOSLULL',
    bankName:
        'Royal Bank of Scotland International Limited, Luxembourg Branch (The)',
    bankShortName:
        'Royal Bank of Scotland International Limited, Luxembourg Branch (The)',
  ),
  '700': Iban(
    bic: 'EWUB LU L2',
    bankName: 'East-West United Bank S.A.',
    bankShortName: 'East-West United Bank S.A.',
  ),
  '701': Iban(
    bic: 'RAPSLUL1',
    bankName: 'Rakuten Europe Bank S.A.',
    bankShortName: 'Rakuten Europe Bank S.A.',
  ),
  '705': Iban(
    bic: 'KBLX LU LL',
    bankName: 'Quintet Private Bank (Europe) S.A.',
    bankShortName: 'Quintet Private Bank (Europe) S.A.',
  ),
  '711': Iban(
    bic: 'DOCKLU22',
    bankName: 'Dock Financial S.A.',
    bankShortName: 'Dock Financial S.A.',
  ),
  '713': Iban(
    bic: 'IBNXLULM',
    bankName: 'iBAN-X S.A.',
    bankShortName: 'iBAN-X S.A.',
  ),
  '777': Iban(
    bic: 'MUGCLULX',
    bankName: 'Mitsubishi UFJ Investor Services & Banking (Luxembourg) S.A.',
    bankShortName:
        'Mitsubishi UFJ Investor Services & Banking (Luxembourg) S.A.',
  ),
  '802': Iban(
    bic: 'SATYLUL1SRV',
    bankName: 'Satispay Europe S.A.',
    bankShortName: 'Satispay Europe S.A.',
  ),
  '805': Iban(
    bic: 'MAGYLUL1',
    bankName: 'MANGOPAY S.A.',
    bankShortName: 'MANGOPAY S.A.',
  ),
  '807': Iban(
    bic: 'SSWILUL1',
    bankName: 'SnapSwap International S.A.',
    bankShortName: 'SnapSwap International S.A.',
  ),
  '810': Iban(
    bic: 'SATYLUL1XXX',
    bankName: 'Satispay Europe S.A.',
    bankShortName: 'Satispay Europe S.A.',
  ),
  '811': Iban(
    bic: 'DOCKLUL2',
    bankName: 'Dock Financial S.A.',
    bankShortName: 'Dock Financial S.A.',
  ),
  '813': Iban(
    bic: 'VPAYLUL2',
    bankName: 'Viva Payment Services S.A. - Luxembourg Branch',
    bankShortName: 'Viva Payment Services S.A. - Luxembourg Branch',
  ),
  '815': Iban(
    bic: 'JOEULUL2',
    bankName: 'Joompay Europe S.A.',
    bankShortName: 'Joompay Europe S.A.',
  ),
  '998': Iban(
    bic: 'BEIL LU LL',
    bankName: 'Banque européenne d’investissement',
    bankShortName: 'Banque européenne d’investissement',
  ),
  '999': Iban(
    bic: 'BCLX LU LL',
    bankName: 'Banque centrale du Luxembourg',
    bankShortName: 'Banque centrale du Luxembourg',
  ),
};

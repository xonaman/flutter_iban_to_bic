part of '../../iban_to_bic.dart';

const Map<String, Bic> _nlBankCodes = <String, Bic>{
  'ABNA': Bic(
    value: 'ABNANL2A',
    bankName: 'ABN AMRO BANK',
    bankShortName: 'ABN AMRO BANK',
  ),
  'ABNC': Bic(
    value: 'ABNCNL2A',
    bankName: 'ABN AMRO Clearing Bank N.V.',
    bankShortName: 'ABN AMRO Clearing Bank N.V.',
  ),
  'ADYB': Bic(
    value: 'ADYBNL2A',
    bankName: 'ADYEN',
    bankShortName: 'ADYEN',
  ),
  'AEGO': Bic(
    value: 'AEGONL2U',
    bankName: 'AEGON BANK',
    bankShortName: 'AEGON BANK',
  ),
  'AINH': Bic(
    value: 'AINHNL22',
    bankName: 'AIRWALLEX (NETHERLANDS) B.V.',
    bankShortName: 'AIRWALLEX (NETHERLANDS) B.V.',
  ),
  'ANDL': Bic(
    value: 'ANDLNL2A',
    bankName: 'ANADOLUBANK',
    bankShortName: 'ANADOLUBANK',
  ),
  'ARBN': Bic(
    value: 'ARBNNL22',
    bankName: 'ACHMEA BANK',
    bankShortName: 'ACHMEA BANK',
  ),
  'ARSN': Bic(
    value: 'ARSNNL21',
    bankName: 'ARGENTA SPAARBANK',
    bankShortName: 'ARGENTA SPAARBANK',
  ),
  'ASNB': Bic(
    value: 'ASNBNL21',
    bankName: 'ASN BANK',
    bankShortName: 'ASN BANK',
  ),
  'BARC': Bic(
    value: 'BARCNL22',
    bankName: 'BARCLAYS BANK',
    bankShortName: 'BARCLAYS BANK',
  ),
  'BCIT': Bic(
    value: 'BCITNL2A',
    bankName: 'INTESA SANPAOLO',
    bankShortName: 'INTESA SANPAOLO',
  ),
  'BICK': Bic(
    value: 'BICKNL2A',
    bankName: 'BINCKBANK',
    bankShortName: 'BINCKBANK',
  ),
  'BINK': Bic(
    value: 'BINKNL21',
    bankName: 'BINCKBANK, PROF',
    bankShortName: 'BINCKBANK, PROF',
  ),
  'BITS': Bic(
    value: 'BITSNL2A',
    bankName: 'BITSAFE PAYMENTS',
    bankShortName: 'BITSAFE PAYMENTS',
  ),
  'BKCH': Bic(
    value: 'BKCHNL2R',
    bankName: 'BANK OF CHINA',
    bankShortName: 'BANK OF CHINA',
  ),
  'BKMG': Bic(
    value: 'BKMGNL2A',
    bankName: 'BANK MENDES GANS',
    bankShortName: 'BANK MENDES GANS',
  ),
  'BLGW': Bic(
    value: 'BLGWNL21',
    bankName: 'BLG WONEN',
    bankShortName: 'BLG WONEN',
  ),
  'BNDA': Bic(
    value: 'BNDANL2A',
    bankName: 'BRAND NEW DAY BANK',
    bankShortName: 'BRAND NEW DAY BANK',
  ),
  'BNGH': Bic(
    value: 'BNGHNL2G',
    bankName: 'BANK NEDERLANDSE GEMEENTEN',
    bankShortName: 'BANK NEDERLANDSE GEMEENTEN',
  ),
  'BNPA': Bic(
    value: 'BNPANL2A',
    bankName: 'BNP PARIBAS',
    bankShortName: 'BNP PARIBAS',
  ),
  'BOFA': Bic(
    value: 'BOFANLNX',
    bankName: 'BANK OF AMERICA',
    bankShortName: 'BANK OF AMERICA',
  ),
  'BOFS': Bic(
    value: 'BOFSNL21002',
    bankName: 'BANK OF SCOTLAND, AMSTERDAM',
    bankShortName: 'BANK OF SCOTLAND, AMSTERDAM',
  ),
  'BOTK': Bic(
    value: 'BOTKNL2X',
    bankName: 'MUFG BANK',
    bankShortName: 'MUFG BANK',
  ),
  'BUNQ': Bic(
    value: 'BUNQNL2A',
    bankName: 'BUNQ',
    bankShortName: 'BUNQ',
  ),
  'CCBV': Bic(
    value: 'CCBVNL2A',
    bankName: 'CURRENCYCLOUD B.V.',
    bankShortName: 'CURRENCYCLOUD B.V.',
  ),
  'CHAS': Bic(
    value: 'CHASNL2X',
    bankName: 'JPMORGAN CHASE',
    bankShortName: 'JPMORGAN CHASE',
  ),
  'CITC': Bic(
    value: 'CITCNL2A',
    bankName: 'CITCO BANK',
    bankShortName: 'CITCO BANK',
  ),
  'CITI': Bic(
    value: 'CITINL2X',
    bankName: 'CITIBANK INTERNATIONAL',
    bankShortName: 'CITIBANK INTERNATIONAL',
  ),
  'COBA': Bic(
    value: 'COBANL2X',
    bankName: 'COMMERZBANK',
    bankShortName: 'COMMERZBANK',
  ),
  'DELE': Bic(
    value: 'DELENL22',
    bankName: 'OYENS & VAN EEGHEN - part of Delen Private Bank',
    bankShortName: 'OYENS & VAN EEGHEN - part of Delen Private Bank',
  ),
  'DEUT': Bic(
    value: 'DEUTNL2A',
    bankName: 'DEUTSCHE BANK (bij alle SEPA-transacties)',
    bankShortName: 'DEUTSCHE BANK (bij alle SEPA-transacties)',
  ),
  'DHBN': Bic(
    value: 'DHBNNL2R',
    bankName: 'DEMIR-HALK BANK',
    bankShortName: 'DEMIR-HALK BANK',
  ),
  'DNIB': Bic(
    value: 'DNIBNL2G',
    bankName: 'NIBC',
    bankShortName: 'NIBC',
  ),
  'EBPB': Bic(
    value: 'EBPBNL22',
    bankName: 'EBURY NETHERLANDS (Brussel entiteit)',
    bankShortName: 'EBURY NETHERLANDS (Brussel entiteit)',
  ),
  'EBUR': Bic(
    value: 'EBURNL21',
    bankName: 'EBURY NETHERLANDS (Londen entiteit)',
    bankShortName: 'EBURY NETHERLANDS (Londen entiteit)',
  ),
  'FBHL': Bic(
    value: 'FBHLNL2A',
    bankName: 'CREDIT EUROPE BANK',
    bankShortName: 'CREDIT EUROPE BANK',
  ),
  'FLOR': Bic(
    value: 'FLORNL2A',
    bankName: 'DE NEDERLANDSCHE BANK',
    bankShortName: 'DE NEDERLANDSCHE BANK',
  ),
  'FNOM': Bic(
    value: 'FNOMNL22',
    bankName: 'FINOM Payments B.V.',
    bankShortName: 'FINOM Payments B.V.',
  ),
  'FRNX': Bic(
    value: 'FRNXNL2A',
    bankName: 'FRANX',
    bankShortName: 'FRANX',
  ),
  'FROM': Bic(
    value: 'FROMNL2A',
    bankName: 'FROMENTY AND CUSTARD E-COMMERCE',
    bankShortName: 'FROMENTY AND CUSTARD E-COMMERCE',
  ),
  'FVLB': Bic(
    value: 'FVLBNL22',
    bankName: 'VAN LANSCHOT',
    bankShortName: 'VAN LANSCHOT',
  ),
  'FXBB': Bic(
    value: 'FXBBNL22',
    bankName: 'IBANFIRST',
    bankShortName: 'IBANFIRST',
  ),
  'GILL': Bic(
    value: 'GILLNL2A',
    bankName: 'INSINGERGILISSEN',
    bankShortName: 'INSINGERGILISSEN',
  ),
  'HAND': Bic(
    value: 'HANDNL2A',
    bankName: 'SVENSKA HANDELSBANKEN',
    bankShortName: 'SVENSKA HANDELSBANKEN',
  ),
  'HIFX': Bic(
    value: 'HIFXNL2A',
    bankName: 'XE EUROPE BV',
    bankShortName: 'XE EUROPE BV',
  ),
  'HUSH': Bic(
    value: 'HUSHNL2A',
    bankName: 'HUSHPAY',
    bankShortName: 'HUSHPAY',
  ),
  'HSBC': Bic(
    value: 'HSBCNL2A',
    bankName: 'HSBC BANK',
    bankShortName: 'HSBC BANK',
  ),
  'ICBC': Bic(
    value: 'ICBCNL2A',
    bankName: 'MEGA INTERNATIONAL COMMERCIAL BANK',
    bankShortName: 'MEGA INTERNATIONAL COMMERCIAL BANK',
  ),
  'ICBK': Bic(
    value: 'ICBKNL2A',
    bankName: 'INDUSTRIAL & COMMERCIAL BANK OF CHINA',
    bankShortName: 'INDUSTRIAL & COMMERCIAL BANK OF CHINA',
  ),
  'ICEP': Bic(
    value: 'ICEPNL21',
    bankName: 'ICEPAY',
    bankShortName: 'ICEPAY',
  ),
  'INGB': Bic(
    value: 'INGBNL2A',
    bankName: 'ING',
    bankShortName: 'ING',
  ),
  'ISAE': Bic(
    value: 'ISAENL2A',
    bankName: 'CACEIS BANK, Netherlands Branch',
    bankShortName: 'CACEIS BANK, Netherlands Branch',
  ),
  'ISBK': Bic(
    value: 'ISBKNL2A',
    bankName: 'ISBANK',
    bankShortName: 'ISBANK',
  ),
  'KABA': Bic(
    value: 'KABANL2A',
    bankName: 'YAPI KREDI BANK',
    bankShortName: 'YAPI KREDI BANK',
  ),
  'KNAB': Bic(
    value: 'KNABNL2H',
    bankName: 'KNAB',
    bankShortName: 'KNAB',
  ),
  'KOEX': Bic(
    value: 'KOEXNL2A',
    bankName: 'KEB HANA BANK',
    bankShortName: 'KEB HANA BANK',
  ),
  'KRED': Bic(
    value: 'KREDNL2X',
    bankName: 'KBC BANK',
    bankShortName: 'KBC BANK',
  ),
  'LOYD': Bic(
    value: 'LOYDNL2A',
    bankName: 'LLOYDS TSB BANK',
    bankShortName: 'LLOYDS TSB BANK',
  ),
  'LPLN': Bic(
    value: 'LPLNNL2F',
    bankName: 'LEASEPLAN CORPORATION',
    bankShortName: 'LEASEPLAN CORPORATION',
  ),
  'MHCB': Bic(
    value: 'MHCBNL2A',
    bankName: 'MIZUHO BANK EUROPE NV',
    bankShortName: 'MIZUHO BANK EUROPE NV',
  ),
  'MODR': Bic(
    value: 'MODRNL22',
    bankName: 'MODULR FINANCE B.V.',
    bankShortName: 'MODULR FINANCE B.V.',
  ),
  'NNBA': Bic(
    value: 'NNBANL2G',
    bankName: 'NATIONALE-NEDERLANDEN BANK',
    bankShortName: 'NATIONALE-NEDERLANDEN BANK',
  ),
  'NWAB': Bic(
    value: 'NWABNL2G',
    bankName: 'NEDERLANDSE WATERSCHAPSBANK',
    bankShortName: 'NEDERLANDSE WATERSCHAPSBANK',
  ),
  'PANX': Bic(
    value: 'PANXNL22',
    bankName: 'UNIFIEDPOST PAYMENTS',
    bankShortName: 'UNIFIEDPOST PAYMENTS',
  ),
  'PCBC': Bic(
    value: 'PCBCNL2A',
    bankName: 'CHINA CONSTRUCTION BANK, AMSTERDAM BRANCH',
    bankShortName: 'CHINA CONSTRUCTION BANK, AMSTERDAM BRANCH',
  ),
  'PNOW': Bic(
    value: 'PNOWNL2A',
    bankName: 'PAY NOW',
    bankShortName: 'PAY NOW',
  ),
  'RABO': Bic(
    value: 'RABONL2U',
    bankName: 'RABOBANK',
    bankShortName: 'RABOBANK',
  ),
  'RBRB': Bic(
    value: 'RBRBNL21',
    bankName: 'REGIOBANK',
    bankShortName: 'REGIOBANK',
  ),
  'REVO': Bic(
    value: 'REVONL22',
    bankName: 'REVOLUT BANK UAB',
    bankShortName: 'REVOLUT BANK UAB',
  ),
  'SBOS': Bic(
    value: 'SBOSNL2A',
    bankName: 'STATE STREET BANK INTERNATIONAL GbmH',
    bankShortName: 'STATE STREET BANK INTERNATIONAL GbmH',
  ),
  'SNSB': Bic(
    value: 'SNSBNL2A',
    bankName: 'SNS',
    bankShortName: 'SNS',
  ),
  'SOGE': Bic(
    value: 'SOGENL2A',
    bankName: 'SOCIETE GENERALE',
    bankShortName: 'SOCIETE GENERALE',
  ),
  'SWNB': Bic(
    value: 'SWNBNL22',
    bankName: 'SWAN',
    bankShortName: 'SWAN',
  ),
  'TRIO': Bic(
    value: 'TRIONL2U',
    bankName: 'TRIODOS BANK',
    bankShortName: 'TRIODOS BANK',
  ),
  'UGBI': Bic(
    value: 'UGBINL2A',
    bankName: 'GARANTIBANK INTERNATIONAL',
    bankShortName: 'GARANTIBANK INTERNATIONAL',
  ),
  'VOWA': Bic(
    value: 'VOWANL21',
    bankName: 'VOLKSWAGEN BANK',
    bankShortName: 'VOLKSWAGEN BANK',
  ),
  'VPAY': Bic(
    value: 'VPAYNL22',
    bankName: 'VIVA PAYMENT SERVICES S.A.',
    bankShortName: 'VIVA PAYMENT SERVICES S.A.',
  ),
  'VTPS': Bic(
    value: 'VTPSNL2R',
    bankName: 'VITESSE PSP',
    bankShortName: 'VITESSE PSP',
  ),
  'YOUR': Bic(
    value: 'YOURNL2A',
    bankName: 'YOURSAFE B.V.',
    bankShortName: 'YOURSAFE B.V.',
  ),
  'ZWLB': Bic(
    value: 'ZWLBNL21',
    bankName: 'SNS ( ex ZWITSERLEVENBANK)',
    bankShortName: 'SNS ( ex ZWITSERLEVENBANK)',
  ),
};

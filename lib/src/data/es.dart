part of '../../iban_to_bic.dart';

const Map<String, Bic> _esBankCodes = <String, Bic>{
  '1000': Bic(
    value: 'ICROESMM',
    bankName: 'Instituto de Crédito Oficial',
    bankShortName: 'Instituto de Crédito Oficial',
    bankAddress: 'Ps del Prado, 4',
    bankPostcode: '28014',
    bankLocation: 'Madrid',
  ),
  '1451': Bic(
    value: 'CRCGESB1',
    bankName:
        'Caisse Régionale de Crédit Agricole Mutuel Sud-Méditerranée (Ariège et Pyrénées-Orientales)',
    bankShortName:
        'Caisse Régionale de Crédit Agricole Mutuel Sud-Méditerranée (Ariège et Pyrénées-Orientales)',
    bankAddress: 'Cl Córcega, 301',
    bankPostcode: '08008',
    bankLocation: 'Barcelona',
  ),
  '1457': Bic(
    value: 'LLISESM1',
    bankName: 'De Lage Landen International B.V., Sucursal en España',
    bankShortName: 'De Lage Landen International B.V., Sucursal en España',
    bankAddress: 'CL  JOSE BARDASANO BAOS, 9',
    bankPostcode: '28016',
    bankLocation: 'MADRID',
  ),
  '1459': Bic(
    value: 'PRABESMM',
    bankName: 'Cooperatieve Rabobank U.A., Sucursal en España',
    bankShortName: 'Cooperatieve Rabobank U.A., Sucursal en España',
    bankAddress: 'Cl Rafael Calvo, 39',
    bankPostcode: '28010',
    bankLocation: 'Madrid',
  ),
  '1460': Bic(
    value: 'CRESESMM',
    bankName: 'Crédit Suisse Ag, Sucursal en España',
    bankShortName: 'Crédit Suisse Ag, Sucursal en España',
    bankAddress: 'Cl Ayala, 42',
    bankPostcode: '28001',
    bankLocation: 'Madrid',
  ),
  '1465': Bic(
    value: 'INGDESMM',
    bankName: 'Ing Bank, N.V. Sucursal en España',
    bankShortName: 'Ing Bank, N.V. Sucursal en España',
    bankAddress: 'VÍA DE LOS POBLADOS, 1F Y 1E',
    bankPostcode: '28033',
    bankLocation: 'Madrid',
  ),
  '1472': Bic(
    value: 'UCSSESM1',
    bankName: 'Crédit Agricole Leasing & Factoring, Sucursal en España',
    bankShortName: 'Crédit Agricole Leasing & Factoring, Sucursal en España',
    bankAddress: 'Ps de la Castellana, 1',
    bankPostcode: '28046',
    bankLocation: 'Madrid',
  ),
  '1473': Bic(
    value: 'PRIBESMX',
    bankName: 'Edmond de Rothschild (Europe), Sucursal en España',
    bankShortName: 'Edmond de Rothschild (Europe), Sucursal en España',
    bankAddress: 'Ps de la Castellana, 55',
    bankPostcode: '28046',
    bankLocation: 'Madrid',
  ),
  '1474': Bic(
    value: 'CITIESMXSEC',
    bankName: 'Citibank Europe Plc, Sucursal en España',
    bankShortName: 'Citibank Europe Plc, Sucursal en España',
    bankAddress: 'ORTEGA Y GASSET 29',
    bankPostcode: '28006',
    bankLocation: 'MADRID',
  ),
  '1479': Bic(
    value: 'NATXESMM',
    bankName: 'Natixis, S.A., Sucursal en España',
    bankShortName: 'Natixis, S.A., Sucursal en España',
    bankAddress: 'Cl Serrano, 90',
    bankPostcode: '28004',
    bankLocation: 'Madrid',
  ),
  '1480': Bic(
    value: 'VOWAES21',
    bankName: 'Volkswagen Bank GmbH, Sucursal en España',
    bankShortName: 'Volkswagen Bank GmbH, Sucursal en España',
    bankAddress: 'AV. DE BRUSELAS, 34',
    bankPostcode: '28108',
    bankLocation: 'ALCOBENDAS',
  ),
  '1485': Bic(
    value: 'BOFAES2X',
    bankName: 'Bank of America Europe DAC, Sucursal en España',
    bankShortName: 'Bank of America Europe DAC, Sucursal en España',
    bankAddress: 'Cl Marqués de Villamagna, 3',
    bankPostcode: '28020',
    bankLocation: 'Madrid',
  ),
  '1490': Bic(
    value: 'SELFESMMXXX',
    bankName: 'Singular Bank, S.A.',
    bankShortName: 'Singular Bank, S.A.',
    bankAddress: 'CALLE GOYA, 11',
    bankPostcode: '28001',
    bankLocation: 'Madrid',
  ),
  '1491': Bic(
    value: 'TRIOES21',
    bankName: 'Triodos Bank, N.V., S.E.',
    bankShortName: 'Triodos Bank, N.V., S.E.',
    bankAddress: 'CL JOSÉ ECHEGARAY, 5',
    bankPostcode: '28230',
    bankLocation: 'LAS ROZAS DE MADRID',
  ),
  '1494': Bic(
    value: 'BCITESMM',
    bankName: 'Intesa Sanpaolo S.p.A., Sucursal en España',
    bankShortName: 'Intesa Sanpaolo S.p.A., Sucursal en España',
    bankAddress: 'Pº de Castellana, 31',
    bankPostcode: '28046',
    bankLocation: 'Madrid',
  ),
  '1497': Bic(
    value: 'ESSIESMM',
    bankName: 'Haitong Bank, S.A., Sucursal en España',
    bankShortName: 'Haitong Bank, S.A., Sucursal en España',
    bankAddress: 'Ps de la Castellana, 52',
    bankPostcode: '28046',
    bankLocation: 'Madrid',
  ),
  '1538': Bic(
    value: 'ICBKESMMXXX',
    bankName:
        'Industrial and Commercial Bank of China (Europe) S.A., Sucursal en España',
    bankShortName:
        'Industrial and Commercial Bank of China (Europe) S.A., Sucursal en España',
    bankAddress: 'Ps de Recoletos, 12',
    bankPostcode: '28001',
    bankLocation: 'Madrid',
  ),
  '1544': Bic(
    value: 'BACAESMM',
    bankName: 'MYINVESTOR BANCO, S.A.',
    bankShortName: 'MYINVESTOR BANCO, S.A.',
    bankAddress: 'Ps de la Castellana, 55',
    bankPostcode: '28046',
    bankLocation: 'Madrid',
  ),
  '1550': Bic(
    value: 'ETICES21',
    bankName:
        'Banca Popolare Etica Società Cooperativa per Azioni, Sucursal en España',
    bankShortName:
        'Banca Popolare Etica Società Cooperativa per Azioni, Sucursal en España',
    bankAddress: 'Cl Santa María, 9',
    bankPostcode: '48005',
    bankLocation: 'Bilbao',
  ),
  '1554': Bic(
    value: 'FASNESM1XXX',
    bankName: 'BFF Bank, S.P.A. Sucursal en España',
    bankShortName: 'BFF Bank, S.P.A. Sucursal en España',
    bankAddress: 'Ps DE LA CASTELLANA, 81',
    bankPostcode: '28046',
    bankLocation: 'Madrid',
  ),
  '1583': Bic(
    value: 'REVOESM2XXX',
    bankName: 'REVOLUT BANK UAB SUCURSAL EN ESPAÑA',
    bankShortName: 'REVOLUT BANK UAB SUCURSAL EN ESPAÑA',
    bankAddress: 'CL PRÍNCIPE DE VERGARA, 132',
    bankPostcode: '28002',
    bankLocation: 'MADRID',
  ),
  '2000': Bic(
    value: 'CECAESMM',
    bankName: 'Cecabank, S.A.',
    bankShortName: 'Cecabank, S.A.',
    bankAddress: 'Cl Alcalá,27',
    bankPostcode: '28014',
    bankLocation: 'Madrid',
  ),
  '2045': Bic(
    value: 'CECAESMM045',
    bankName: 'Caja de Ahorros y Monte de Piedad de Ontinyent',
    bankShortName: 'Caja de Ahorros y Monte de Piedad de Ontinyent',
    bankAddress: 'PZ SANTO DOMINGO, 24',
    bankPostcode: '46870',
    bankLocation: 'ONTINYENT',
  ),
  '2056': Bic(
    value: 'CECAESMM056',
    bankName: "Colonya - Caixa D'estalvis de Pollensa",
    bankShortName: "Colonya - Caixa D'estalvis de Pollensa",
    bankAddress: 'PZ MAYOR, 7',
    bankPostcode: '07460',
    bankLocation: 'POLLENÇA',
  ),
  '2080': Bic(
    value: 'CAGLESMMVIG',
    bankName: 'Abanca Corporacion Bancaria, S.A.',
    bankShortName: 'Abanca Corporacion Bancaria, S.A.',
    bankAddress: 'CI Cantón Claudino Pita, 2',
    bankPostcode: '15300',
    bankLocation: 'Betanzos',
  ),
  '2085': Bic(
    value: 'CAZRES2Z',
    bankName: 'Ibercaja Banco, S.A.',
    bankShortName: 'Ibercaja Banco, S.A.',
    bankAddress: 'Pz D. Basilio Paraíso, 2',
    bankPostcode: '50008',
    bankLocation: 'Zaragoza',
  ),
  '2095': Bic(
    value: 'BASKES2B',
    bankName: 'Kutxabank, S.A.',
    bankShortName: 'Kutxabank, S.A.',
    bankAddress: 'CL GRAN VÍA, 30-32',
    bankPostcode: '48009',
    bankLocation: 'BILBAO',
  ),
  '2100': Bic(
    value: 'CAIXESBB',
    bankName: 'Caixabank, S.A.',
    bankShortName: 'Caixabank, S.A.',
    bankAddress: 'Cl Pintor Sorolla 2-4',
    bankPostcode: '46002',
    bankLocation: 'Valencia',
  ),
  '2103': Bic(
    value: 'UCJAES2M',
    bankName: 'Unicaja Banco, S.A.',
    bankShortName: 'Unicaja Banco, S.A.',
    bankAddress: 'Av Andalucía, 10-12',
    bankPostcode: '29007',
    bankLocation: 'Málaga',
  ),
  '3001': Bic(
    value: 'BCOEESMM001',
    bankName: 'Caja Rural de Almendralejo, Sociedad Cooperativa de Crédito',
    bankShortName:
        'Caja Rural de Almendralejo, Sociedad Cooperativa de Crédito',
    bankAddress: 'PZ DE SAN ANTONIO, SN',
    bankPostcode: '06200',
    bankLocation: 'ALMENDRALEJO',
  ),
  '3005': Bic(
    value: 'BCOEESMM005',
    bankName: 'Caja Rural Central, Sociedad Cooperativa de Crédito',
    bankShortName: 'Caja Rural Central, Sociedad Cooperativa de Crédito',
    bankAddress: 'CL JOSÉ MARÍA SARGET 29',
    bankPostcode: '03300',
    bankLocation: 'ORIHUELA',
  ),
  '3007': Bic(
    value: 'BCOEESMM007',
    bankName: 'Caja Rural de Gijón, Sociedad Cooperativa Asturiana de Crédito',
    bankShortName:
        'Caja Rural de Gijón, Sociedad Cooperativa Asturiana de Crédito',
    bankAddress: 'PS DE LA INFANCIA, 10',
    bankPostcode: '33207',
    bankLocation: 'GIJON',
  ),
  '3008': Bic(
    value: 'BCOEESMM008',
    bankName: 'Caja Rural de Navarra, S. Coop. de Crédito',
    bankShortName: 'Caja Rural de Navarra, S. Coop. de Crédito',
    bankAddress: 'PZ DE LOS FUEROS, 1',
    bankPostcode: '31003',
    bankLocation: 'PAMPLONA/IRUÑA',
  ),
  '3009': Bic(
    value: 'BCOEESMM009',
    bankName: 'Caja Rural de Extremadura, Sociedad Cooperativa de Crédito',
    bankShortName: 'Caja Rural de Extremadura, Sociedad Cooperativa de Crédito',
    bankAddress: 'Av de Santa Marina 15',
    bankPostcode: '06005',
    bankLocation: 'Badajoz',
  ),
  '3016': Bic(
    value: 'BCOEESMM016',
    bankName: 'Caja Rural de Salamanca, Sociedad Cooperativa de Crédito',
    bankShortName: 'Caja Rural de Salamanca, Sociedad Cooperativa de Crédito',
    bankAddress: 'Puerta de Zamora, 2',
    bankPostcode: '37005',
    bankLocation: 'Salamanca',
  ),
  '3017': Bic(
    value: 'BCOEESMM017',
    bankName: 'Caja Rural de Soria, Sociedad Cooperativa de Crédito',
    bankShortName: 'Caja Rural de Soria, Sociedad Cooperativa de Crédito',
    bankAddress: 'Cl Diputación,1',
    bankPostcode: '42003',
    bankLocation: 'Soria',
  ),
  '3018': Bic(
    value: 'BCOEESMM018',
    bankName:
        'Caja Rural Regional San Agustín Fuente Álamo Murcia, Sociedad Cooperativa de Crédito',
    bankShortName:
        'Caja Rural Regional San Agustín Fuente Álamo Murcia, Sociedad Cooperativa de Crédito',
    bankAddress: 'Gran Vía, 1',
    bankPostcode: '30320',
    bankLocation: 'Fuente Álamo',
  ),
  '3020': Bic(
    value: 'BCOEESMM020',
    bankName: 'Caja Rural de Utrera, Sociedad Cooperativa Andaluza de Crédito',
    bankShortName:
        'Caja Rural de Utrera, Sociedad Cooperativa Andaluza de Crédito',
    bankAddress: 'PZ DEL ALTOZANO, 22',
    bankPostcode: '41710',
    bankLocation: 'UTRERA',
  ),
  '3023': Bic(
    value: 'BCOEESMM023',
    bankName: 'Caja Rural de Granada, Sociedad Cooperativa de Crédito',
    bankShortName: 'Caja Rural de Granada, Sociedad Cooperativa de Crédito',
    bankAddress: 'Av Don Bosco, 2',
    bankPostcode: '18006',
    bankLocation: 'Granada',
  ),
  '3025': Bic(
    value: 'CDENESBB',
    bankName:
        'Caixa de Crédit dels Enginyers- Caja de Crédito de los Ingenieros, S. Coop. de Crédito',
    bankShortName:
        'Caixa de Crédit dels Enginyers- Caja de Crédito de los Ingenieros, S. Coop. de Crédito',
    bankAddress: 'Via Laietana, 39',
    bankPostcode: '08003',
    bankLocation: 'Barcelona',
  ),
  '3029': Bic(
    value: 'CCRIES2A029',
    bankName:
        'Caja de Crédito de Petrel, Caja Rural, Cooperativa de Crédito Valenciana',
    bankShortName:
        'Caja de Crédito de Petrel, Caja Rural, Cooperativa de Crédito Valenciana',
    bankAddress: 'CL SAN BARTOLOMÉ,2',
    bankPostcode: '03610',
    bankLocation: 'PETRER',
  ),
  '3035': Bic(
    value: 'CLPEES2M',
    bankName: 'Caja Laboral Popular Coop. de Crédito',
    bankShortName: 'Caja Laboral Popular Coop. de Crédito',
    bankAddress: 'PS JOSE MARÍA ARIZMENDIARRIETA SN',
    bankPostcode: '20500',
    bankLocation: 'ARRASATE/MONDRAGON',
  ),
  '3045': Bic(
    value: 'CCRIES2A045',
    bankName: 'Caixa Rural Altea, Cooperativa de Crédito Valenciana',
    bankShortName: 'Caixa Rural Altea, Cooperativa de Crédito Valenciana',
    bankAddress: 'PLACETA DEL CONVENT, 2',
    bankPostcode: '03590',
    bankLocation: 'ALTEA',
  ),
  '3058': Bic(
    value: 'CCRIES2A',
    bankName: 'Cajamar Caja Rural, Sociedad Cooperativa de Crédito',
    bankShortName: 'Cajamar Caja Rural, Sociedad Cooperativa de Crédito',
    bankAddress: 'Pz Barcelona, 5',
    bankPostcode: '04006',
    bankLocation: 'Almería',
  ),
  '3059': Bic(
    value: 'BCOEESMM059',
    bankName: 'Caja Rural de Asturias, Sociedad Cooperativa de Crédito',
    bankShortName: 'Caja Rural de Asturias, Sociedad Cooperativa de Crédito',
    bankAddress: 'Cl Melquiades Álvarez,7',
    bankPostcode: '33002',
    bankLocation: 'Oviedo',
  ),
  '3060': Bic(
    value: 'BCOEESMM060',
    bankName:
        'Caja Rural de Burgos, Fuentepelayo, Segovia y Castelldans, Sociedad Cooperativa de Crédito',
    bankShortName:
        'Caja Rural de Burgos, Fuentepelayo, Segovia y Castelldans, Sociedad Cooperativa de Crédito',
    bankAddress: 'Cl. LosCoches, 2-4',
    bankPostcode: '40002',
    bankLocation: 'Segovia',
  ),
  '3067': Bic(
    value: 'BCOEESMM067',
    bankName:
        'Caja Rural de Jaén, Barcelona y Madrid, Sociedad Cooperativa de Crédito',
    bankShortName:
        'Caja Rural de Jaén, Barcelona y Madrid, Sociedad Cooperativa de Crédito',
    bankAddress: 'CL EL CONDADO, 23',
    bankPostcode: '23620',
    bankLocation: 'MENGIBAR',
  ),
  '3070': Bic(
    value: 'BCOEESMM070',
    bankName:
        'Caixa Rural Galega, Sociedad Cooperativa de Crédito Limitada Gallega',
    bankShortName:
        'Caixa Rural Galega, Sociedad Cooperativa de Crédito Limitada Gallega',
    bankAddress: 'Av de Montero Ríos, 24-26',
    bankPostcode: '27002',
    bankLocation: 'Lugo',
  ),
  '3076': Bic(
    value: 'BCOEESMM076',
    bankName: 'Cajasiete, Caja Rural, Sociedad Cooperativa de Crédito',
    bankShortName: 'Cajasiete, Caja Rural, Sociedad Cooperativa de Crédito',
    bankAddress: 'Av Manuel Hermoso Rojas, 8',
    bankPostcode: '38003',
    bankLocation: 'Santa Cruz de Tenerife',
  ),
  '3080': Bic(
    value: 'BCOEESMM080',
    bankName: 'Caja Rural de Teruel, Sociedad Cooperativa de Crédito',
    bankShortName: 'Caja Rural de Teruel, Sociedad Cooperativa de Crédito',
    bankAddress: 'Pz Carlos Castel, 14',
    bankPostcode: '44001',
    bankLocation: 'Teruel',
  ),
  '3081': Bic(
    value: 'ERSVES22XXX',
    bankName: 'Eurocaja Rural, Sociedad Cooperativa de Crédito',
    bankShortName: 'Eurocaja Rural, Sociedad Cooperativa de Crédito',
    bankAddress: 'Cl Méjico, 2',
    bankPostcode: '45004',
    bankLocation: 'Toledo',
  ),
  '3085': Bic(
    value: 'BCOEESMM085',
    bankName: 'Caja Rural de Zamora, Cooperativa de Crédito',
    bankShortName: 'Caja Rural de Zamora, Cooperativa de Crédito',
    bankAddress: 'Av Alfonso IX, 7',
    bankPostcode: '49014',
    bankLocation: 'Zamora',
  ),
  '3089': Bic(
    value: 'BCOEESMM089',
    bankName:
        'Caja Rural de Baena Ntra. Sra. de Guadalupe Sociedad Cooperativa de Crédito Andaluza',
    bankShortName:
        'Caja Rural de Baena Ntra. Sra. de Guadalupe Sociedad Cooperativa de Crédito Andaluza',
    bankAddress: 'CL  DUQUE DE RIVAS, 3',
    bankPostcode: '14850',
    bankLocation: 'BAENA',
  ),
  '3095': Bic(
    value: 'CCRIES2A095',
    bankName: 'Caja Rural San Roque de Almenara S. Coop. de Crédito  V.',
    bankShortName: 'Caja Rural San Roque de Almenara S. Coop. de Crédito  V.',
    bankAddress: 'CL DR. BERENGUER, 4',
    bankPostcode: '12590',
    bankLocation: 'ALMENARA',
  ),
  '3096': Bic(
    value: 'BCOEESMM096',
    bankName:
        "Caixa Rural de L'Alcudia, Sociedad Cooperativa Valenciana de Crédito",
    bankShortName:
        "Caixa Rural de L'Alcudia, Sociedad Cooperativa Valenciana de Crédito",
    bankAddress: "AV VERGE DE L'ORETO 2",
    bankPostcode: '46250',
    bankLocation: "L' ALCUDIA",
  ),
  '3098': Bic(
    value: 'BCOEESMM098',
    bankName:
        'Caja Rural de Nueva Carteya,  Sociedad Cooperativa Andaluza de Crédito',
    bankShortName:
        'Caja Rural de Nueva Carteya,  Sociedad Cooperativa Andaluza de Crédito',
    bankAddress: 'AV ANDALUCÍA, 6',
    bankPostcode: '14857',
    bankLocation: 'NUEVA CARTEYA',
  ),
  '3102': Bic(
    value: 'CCRIES2A102',
    bankName:
        "Caixa Rural Sant Vicent Ferrer de La Vall D'Uixó, Coop.de Credit V.",
    bankShortName:
        "Caixa Rural Sant Vicent Ferrer de La Vall D'Uixó, Coop.de Credit V.",
    bankAddress: 'PZ DEL CENTRO, 4',
    bankPostcode: '12600',
    bankLocation: "LA VALL D'UIXO",
  ),
  '3104': Bic(
    value: 'BCOEESMM104',
    bankName:
        'Caja Rural de Cañete de Las Torres Ntra. Sra. del Campo Sociedad Cooperativa Andaluza de Crédito',
    bankShortName:
        'Caja Rural de Cañete de Las Torres Ntra. Sra. del Campo Sociedad Cooperativa Andaluza de Crédito',
    bankAddress: 'PZA DE ESPAÑA, 5',
    bankPostcode: '14660',
    bankLocation: 'CAÑETE DE LAS TORRES',
  ),
  '3105': Bic(
    value: 'CCRIES2A105',
    bankName:
        "Caixa Rural de Callosa d'en Sarrià, Cooperativa de Crédito Valenciana",
    bankShortName:
        "Caixa Rural de Callosa d'en Sarrià, Cooperativa de Crédito Valenciana",
    bankAddress: 'AV JAIME I, 1',
    bankPostcode: '03510',
    bankLocation: "CALLOSA D'EN SARRIA",
  ),
  '3110': Bic(
    value: 'CCRIES2A110',
    bankName: 'Caja Rural Católico Agraria, S. Coop. de Crédito V.',
    bankShortName: 'Caja Rural Católico Agraria, S. Coop. de Crédito V.',
    bankAddress: 'PZ MAYOR, 10',
    bankPostcode: '12540',
    bankLocation: 'VILA-REAL',
  ),
  '3111': Bic(
    value: 'BCOEESMM111',
    bankName:
        "Caixa Rural La Vall 'San Isidro', Sociedad Cooperativa de Crédito Valenciana",
    bankShortName:
        "Caixa Rural La Vall 'San Isidro', Sociedad Cooperativa de Crédito Valenciana",
    bankAddress: 'AV CORAZÓN DE JESÚS, 3',
    bankPostcode: '12600',
    bankLocation: "LA VALL D'UIXO",
  ),
  '3112': Bic(
    value: 'CCRIES2A112',
    bankName: 'Caja Rural San José de Burriana, S. Coop. de Crédito V.',
    bankShortName: 'Caja Rural San José de Burriana, S. Coop. de Crédito V.',
    bankAddress: 'PZ EL PLA, 1',
    bankPostcode: '12530',
    bankLocation: 'BORRIANA/BURRIANA',
  ),
  '3113': Bic(
    value: 'BCOEESMM113',
    bankName: 'Caja Rural San José de Alcora S. Coop. de Crédito V.',
    bankShortName: 'Caja Rural San José de Alcora S. Coop. de Crédito V.',
    bankAddress: 'CL SAN FRANCISCO, 14',
    bankPostcode: '12110',
    bankLocation: "L' ALCORA",
  ),
  '3115': Bic(
    value: 'BCOEESMM115',
    bankName:
        "Caja Rural 'Nuestra Madre del Sol', S. Coop. Andaluza de Crédito",
    bankShortName:
        "Caja Rural 'Nuestra Madre del Sol', S. Coop. Andaluza de Crédito",
    bankAddress: 'CL ALTO GUADALQUIVIR, 4',
    bankPostcode: '14430',
    bankLocation: 'ADAMUZ',
  ),
  '3117': Bic(
    value: 'BCOEESMM117',
    bankName: "Caixa Rural D'Algemesí, S. Coop. V. de Crédit",
    bankShortName: "Caixa Rural D'Algemesí, S. Coop. V. de Crédit",
    bankAddress: 'CL SAN JOSÉ DE CALASANZ, 6',
    bankPostcode: '46680',
    bankLocation: 'ALGEMESI',
  ),
  '3118': Bic(
    value: 'CCRIES2A118',
    bankName: 'Caixa Rural Torrent Cooperativa de Credit Valenciana',
    bankShortName: 'Caixa Rural Torrent Cooperativa de Credit Valenciana',
    bankAddress: 'AV AL VEDAT, 3',
    bankPostcode: '46900',
    bankLocation: 'TORRENT',
  ),
  '3119': Bic(
    value: 'CCRIES2A119',
    bankName:
        'Caja Rural San Jaime de Alquerías Niño Perdido S. Coop. de Crédito V.',
    bankShortName:
        'Caja Rural San Jaime de Alquerías Niño Perdido S. Coop. de Crédito V.',
    bankAddress: 'CL JAIME CHICHARRO 24',
    bankPostcode: '12539',
    bankLocation: 'ALQUERIAS DEL NIÑO PERDIDO',
  ),
  '3121': Bic(
    value: 'CCRIES2A121',
    bankName:
        'Caja Rural de Cheste, Sociedad Cooperativa de Crédito Valenciana',
    bankShortName:
        'Caja Rural de Cheste, Sociedad Cooperativa de Crédito Valenciana',
    bankAddress: 'PZ DR. CAJAL, 2',
    bankPostcode: '46380',
    bankLocation: 'CHESTE',
  ),
  '3123': Bic(
    value: 'CCRIES2A123',
    bankName: 'Caixa Rural de Turís, Cooperativa de Crédito Valenciana',
    bankShortName: 'Caixa Rural de Turís, Cooperativa de Crédito Valenciana',
    bankAddress: 'PZ CONSTITUCIÓN, 2',
    bankPostcode: '46389',
    bankLocation: 'TURIS',
  ),
  '3127': Bic(
    value: 'BCOEESMM127',
    bankName:
        'Caja Rural de Casas Ibáñez, S. Coop. de Crédito de Castilla-La Mancha',
    bankShortName:
        'Caja Rural de Casas Ibáñez, S. Coop. de Crédito de Castilla-La Mancha',
    bankAddress: 'CL TERCIA, 49',
    bankPostcode: '02200',
    bankLocation: 'CASAS-IBAÑEZ',
  ),
  '3130': Bic(
    value: 'BCOEESMM130',
    bankName: 'Caja Rural San José de Almassora, S. Coop. de Crédito V.',
    bankShortName: 'Caja Rural San José de Almassora, S. Coop. de Crédito V.',
    bankAddress: 'CL TRINIDAD, 20',
    bankPostcode: '12550',
    bankLocation: 'ALMAZORA/ALMASSORA',
  ),
  '3134': Bic(
    value: 'BCOEESMM134',
    bankName:
        'Caja Rural Nuestra Señora de la Esperanza de Onda, S. Coop. de Crédito V.',
    bankShortName:
        'Caja Rural Nuestra Señora de la Esperanza de Onda, S. Coop. de Crédito V.',
    bankAddress: 'PZ EL PLÁ, 19',
    bankPostcode: '12200',
    bankLocation: 'ONDA',
  ),
  '3135': Bic(
    value: 'CCRIES2A135',
    bankName: 'Caja Rural San José de Nules S. Coop. de Crédito V.',
    bankShortName: 'Caja Rural San José de Nules S. Coop. de Crédito V.',
    bankAddress: 'CL MAYOR, 66',
    bankPostcode: '12520',
    bankLocation: 'NULES',
  ),
  '3138': Bic(
    value: 'BCOEESMM138',
    bankName: 'Ruralnostra, Sociedad Cooperativa de Crédito Valenciana',
    bankShortName: 'Ruralnostra, Sociedad Cooperativa de Crédito Valenciana',
    bankAddress: 'PZ MAYOR, 2',
    bankPostcode: '12549',
    bankLocation: 'BETXI',
  ),
  '3140': Bic(
    value: 'BCOEESMM140',
    bankName: 'Caja Rural de Guissona, Sociedad Cooperativa de Crédito',
    bankShortName: 'Caja Rural de Guissona, Sociedad Cooperativa de Crédito',
    bankAddress: 'CL TRASPALAU, 8',
    bankPostcode: '25210',
    bankLocation: 'GUISSONA',
  ),
  '3144': Bic(
    value: 'BCOEESMM144',
    bankName:
        'Caja Rural de Villamalea, S. Coop. de Crédito Agrario de Castilla-La Mancha',
    bankShortName:
        'Caja Rural de Villamalea, S. Coop. de Crédito Agrario de Castilla-La Mancha',
    bankAddress: 'PZ DE LA CONCEPCIÓN, 1',
    bankPostcode: '02270',
    bankLocation: 'VILLAMALEA',
  ),
  '3150': Bic(
    value: 'BCOEESMM150',
    bankName: 'Caja Rural de Albal, Coop. de Crédito V.',
    bankShortName: 'Caja Rural de Albal, Coop. de Crédito V.',
    bankAddress: 'PZ DEL JARDÍ, 24',
    bankPostcode: '46470',
    bankLocation: 'ALBAL',
  ),
  '3152': Bic(
    value: 'CCRIES2A152',
    bankName: 'Caja Rural de Villar, Coop. de Crédito V.',
    bankShortName: 'Caja Rural de Villar, Coop. de Crédito V.',
    bankAddress: 'CL LAS CRUCES 33',
    bankPostcode: '46170',
    bankLocation: 'VILLAR DEL ARZOBISPO',
  ),
  '3157': Bic(
    value: 'CCRIES2A157',
    bankName: 'Caja Rural La Junquera de Chilches, S. Coop. de Crédito V.',
    bankShortName: 'Caja Rural La Junquera de Chilches, S. Coop. de Crédito V.',
    bankAddress: 'PZ DE ESPAÑA, 8',
    bankPostcode: '12592',
    bankLocation: 'CHILCHES/XILXES',
  ),
  '3159': Bic(
    value: 'BCOEESMM159',
    bankName: 'Caixa Popular-Caixa Rural, S. Coop. de Crédito V.',
    bankShortName: 'Caixa Popular-Caixa Rural, S. Coop. de Crédito V.',
    bankAddress: 'AV JUAN DE LA CIERVA, 9',
    bankPostcode: '46980',
    bankLocation: 'PATERNA',
  ),
  '3160': Bic(
    value: 'CCRIES2A160',
    bankName: 'Caixa Rural Sant Josep de Vilavella, S. Coop. de Crédito V.',
    bankShortName:
        'Caixa Rural Sant Josep de Vilavella, S. Coop. de Crédito V.',
    bankAddress: 'CL CUEVA SANTA, 11',
    bankPostcode: '12526',
    bankLocation: 'VILABELLA',
  ),
  '3162': Bic(
    value: 'BCOEESMM162',
    bankName: 'Caixa Rural Benicarló, S. Coop. de Credit V.',
    bankShortName: 'Caixa Rural Benicarló, S. Coop. de Credit V.',
    bankAddress: 'AV JOAN CARLES I, 18',
    bankPostcode: '12580',
    bankLocation: 'BENICARLO',
  ),
  '3165': Bic(
    value: 'CCRIES2A165',
    bankName: 'Caja Rural San Isidro de Vilafames S. Coop. de Crédito V.',
    bankShortName: 'Caja Rural San Isidro de Vilafames S. Coop. de Crédito V.',
    bankAddress: 'AV DE BARCELÓ, 6',
    bankPostcode: '12192',
    bankLocation: 'VILAFAMES',
  ),
  '3166': Bic(
    value: 'BCOEESMM166',
    bankName: 'Caixa Rural Les Coves de Vinromá, S. Coop. de Crédit V.',
    bankShortName: 'Caixa Rural Les Coves de Vinromá, S. Coop. de Crédit V.',
    bankAddress: 'CL SAN ANTONIO, 27',
    bankPostcode: '12185',
    bankLocation: 'LES COVES DE VINROMA',
  ),
  '3174': Bic(
    value: 'BCOEESMM174',
    bankName: 'Caixa Rural Vinarós, S. Coop. de Credit. V.',
    bankShortName: 'Caixa Rural Vinarós, S. Coop. de Credit. V.',
    bankAddress: 'CL SAN CRISTÓBAL, 19',
    bankPostcode: '12500',
    bankLocation: 'VINAROS',
  ),
  '3179': Bic(
    value: 'CCRIES2A179',
    bankName: 'Caja Rural de Alginet, Sociedad Cooperativa Crédito Valenciana',
    bankShortName:
        'Caja Rural de Alginet, Sociedad Cooperativa Crédito Valenciana',
    bankAddress: 'CL VALENCIA 13',
    bankPostcode: '46230',
    bankLocation: 'ALGINET',
  ),
  '3183': Bic(
    value: 'CASDESBB',
    bankName: 'Arquia Bank, S.A.',
    bankShortName: 'Arquia Bank, S.A.',
    bankAddress: 'CL TUTOR, 16',
    bankPostcode: '28008',
    bankLocation: 'MADRID',
  ),
  '3187': Bic(
    value: 'BCOEESMM187',
    bankName: 'Caja Rural del Sur, S. Coop. de Crédito',
    bankShortName: 'Caja Rural del Sur, S. Coop. de Crédito',
    bankAddress: 'Cl Murillo 2',
    bankPostcode: '41001',
    bankLocation: 'Sevilla',
  ),
  '3190': Bic(
    value: 'BCOEESMM190',
    bankName:
        'Caja Rural de Albacete, Ciudad Real y Cuenca, Sociedad Cooperativa de Crédito',
    bankShortName:
        'Caja Rural de Albacete, Ciudad Real y Cuenca, Sociedad Cooperativa de Crédito',
    bankAddress: 'Cl Tesifonte Gallego, 18',
    bankPostcode: '02002',
    bankLocation: 'Albacete',
  ),
  '3191': Bic(
    value: 'BCOEESMM191',
    bankName: 'Caja Rural de Aragón, Sociedad Cooperativa de Crédito',
    bankShortName: 'Caja Rural de Aragón, Sociedad Cooperativa de Crédito',
    bankAddress: 'CI Coso 29',
    bankPostcode: '50003',
    bankLocation: 'Zaragoza',
  ),
  '0003': Bic(
    value: 'BDEPESM1',
    bankName: 'Banco de Depósitos, S.A.',
    bankShortName: 'Banco de Depósitos, S.A.',
    bankAddress: 'PS DE LA CASTELLANA, 120',
    bankPostcode: '28046',
    bankLocation: 'MADRID',
  ),
  '0011': Bic(
    value: 'ALLFESMM',
    bankName: 'Allfunds Bank, S.A.',
    bankShortName: 'Allfunds Bank, S.A.',
    bankAddress: 'Cl Padres Dominicos, 7',
    bankPostcode: '28050',
    bankLocation: 'Madrid',
  ),
  '0019': Bic(
    value: 'DEUTESBBASS',
    bankName: 'Deutsche Bank, Sociedad Anónima Española',
    bankShortName: 'Deutsche Bank, Sociedad Anónima Española',
    bankAddress: 'Ps de la Castellana, 18',
    bankPostcode: '28046',
    bankLocation: 'Madrid',
  ),
  '0036': Bic(
    value: 'SABNESMMSSS',
    bankName: 'Santander Investment, S.A.',
    bankShortName: 'Santander Investment, S.A.',
    bankAddress: 'AV DE CANTABRIA, SN',
    bankPostcode: '28660',
    bankLocation: 'BOADILLA DEL MONTE',
  ),
  '0038': Bic(
    value: 'BSSSESM2',
    bankName: 'CACEIS Bank Spain, S.A.',
    bankShortName: 'CACEIS Bank Spain, S.A.',
    bankAddress: 'PQ.EMPRESARIAL LA FINCA-P.CLUB DEPORTIVO',
    bankPostcode: '28223',
    bankLocation: 'POZUELO DE ALARCON',
  ),
  '0049': Bic(
    value: 'BSCHESMM',
    bankName: 'Banco Santander, S.A.',
    bankShortName: 'Banco Santander, S.A.',
    bankAddress: 'Ps de Pereda, 9-12',
    bankPostcode: '39004',
    bankLocation: 'Santander',
  ),
  '0061': Bic(
    value: 'BMARES2M',
    bankName: 'Banca March, S.A.',
    bankShortName: 'Banca March, S.A.',
    bankAddress: 'AV DE ALEJANDRO ROSELLÓ, 8',
    bankPostcode: '07002',
    bankLocation: 'PALMA',
  ),
  '0073': Bic(
    value: 'OPENESMM',
    bankName: 'Open Bank, S.A.',
    bankShortName: 'Open Bank, S.A.',
    bankAddress: 'PLAZA DE SANTA BARBARA, 2',
    bankPostcode: '28004',
    bankLocation: 'Madrid',
  ),
  '0078': Bic(
    value: 'BAPUES22',
    bankName: 'Banca Pueyo, S.A.',
    bankShortName: 'Banca Pueyo, S.A.',
    bankAddress: 'CL SANTA MARÍA DE GUADALUPE, 2',
    bankPostcode: '06700',
    bankLocation: 'VILLANUEVA DE LA SERENA',
  ),
  '0081': Bic(
    value: 'BSABESBB',
    bankName: 'Banco de Sabadell, S.A.',
    bankShortName: 'Banco de Sabadell, S.A.',
    bankAddress: 'Av. Óscar Esplá, 30',
    bankPostcode: '03007',
    bankLocation: 'Alicante',
  ),
  '0083': Bic(
    value: 'RENBESMM',
    bankName: 'Renta 4 Banco, S.A.',
    bankShortName: 'Renta 4 Banco, S.A.',
    bankAddress: 'Ps de la Habana, 74',
    bankPostcode: '28036',
    bankLocation: 'Madrid',
  ),
  '0091': Bic(
    value: 'ALACESM1',
    bankName: 'Banco de Albacete, S.A.',
    bankShortName: 'Banco de Albacete, S.A.',
    bankAddress: 'AV DE CANTABRIA, SN',
    bankPostcode: '28660',
    bankLocation: 'BOADILLA DEL MONTE',
  ),
  '0108': Bic(
    value: 'SOGEESMMAGM',
    bankName: 'Société Genérale, Sucursal en España',
    bankShortName: 'Société Genérale, Sucursal en España',
    bankAddress: 'Pz Pablo Ruiz Picasso, 1',
    bankPostcode: '28020',
    bankLocation: 'Madrid',
  ),
  '0121': Bic(
    value: 'OCBAESM1',
    bankName: 'Banco Occidental, S.A.',
    bankShortName: 'Banco Occidental, S.A.',
    bankAddress: 'Cl Azul, 4',
    bankPostcode: '28050',
    bankLocation: 'Madrid',
  ),
  '0128': Bic(
    value: 'BKBKESMM',
    bankName: 'Bankinter, S.A.',
    bankShortName: 'Bankinter, S.A.',
    bankAddress: 'Ps de la Castellana 29',
    bankPostcode: '28046',
    bankLocation: 'Madrid',
  ),
  '0136': Bic(
    value: 'AREBESMM',
    bankName: 'Aresbank, S.A.',
    bankShortName: 'Aresbank, S.A.',
    bankAddress: 'Ps de la Castellana, 257',
    bankPostcode: '28046',
    bankLocation: 'Madrid',
  ),
  '0145': Bic(
    value: 'DEUTESM1',
    bankName: 'Deutsche Bank, A.G., Sucursal en España',
    bankShortName: 'Deutsche Bank, A.G., Sucursal en España',
    bankAddress: 'Ps de la Castellana, 18',
    bankPostcode: '28046',
    bankLocation: 'Madrid',
  ),
  '0149': Bic(
    value: 'BNPAESMH',
    bankName: 'BNP Paribas S.A., Sucursal en España',
    bankShortName: 'BNP Paribas S.A., Sucursal en España',
    bankAddress: 'Cl Emilio Vargas, 4',
    bankPostcode: '28043',
    bankLocation: 'Madrid',
  ),
  '0151': Bic(
    value: 'CHASESM3',
    bankName: 'JPMorgan Chase Bank National Association, Sucursal en España',
    bankShortName:
        'JPMorgan Chase Bank National Association, Sucursal en España',
    bankAddress: 'Ps Castellana, 31',
    bankPostcode: '28045',
    bankLocation: 'Madrid',
  ),
  '0152': Bic(
    value: 'BPLCESMM',
    bankName: 'Barclays Bank Ireland PLC, Sucursal en España',
    bankShortName: 'Barclays Bank Ireland PLC, Sucursal en España',
    bankAddress: 'Cl José Abascal, 51',
    bankPostcode: '28003',
    bankLocation: 'Madrid',
  ),
  '0154': Bic(
    value: 'BSUIESMM',
    bankName:
        'Crédit Agricole Corporate and Investment Bank, Sucursal en España',
    bankShortName:
        'Crédit Agricole Corporate and Investment Bank, Sucursal en España',
    bankAddress: 'Ps de la Castellana , 1',
    bankPostcode: '28046',
    bankLocation: 'Madrid',
  ),
  '0159': Bic(
    value: 'COBAESMXTMA',
    bankName: 'Commerzbank Aktiengesellschaft, Sucursal en España',
    bankShortName: 'Commerzbank Aktiengesellschaft, Sucursal en España',
    bankAddress: 'Ps de la Castellana 259, pl 32',
    bankPostcode: '28046',
    bankLocation: 'Madrid',
  ),
  '0160': Bic(
    value: 'BOTKESMX',
    bankName: 'MUFG Bank (Europe) N.V., Sucursal en España',
    bankShortName: 'MUFG Bank (Europe) N.V., Sucursal en España',
    bankAddress: 'Cl José Ortega y Gasset, 29',
    bankPostcode: '28006',
    bankLocation: 'Madrid',
  ),
  '0162': Bic(
    value: 'MIDLESMX',
    bankName: 'HSBC Continental Europe, Sucursal en España',
    bankShortName: 'HSBC Continental Europe, Sucursal en España',
    bankAddress: 'Pz Pablo Ruiz Picasso sn Pl.33. Torre Picasso',
    bankPostcode: '28020',
    bankLocation: 'Madrid',
  ),
  '0167': Bic(
    value: 'GEBAESMMBIL',
    bankName: 'BNP Paribas Fortis, S.A., N.V., Sucursal en España',
    bankShortName: 'BNP Paribas Fortis, S.A., N.V., Sucursal en España',
    bankAddress: 'Cl Emilio Vargas, 4',
    bankPostcode: '28043',
    bankLocation: 'Madrid',
  ),
  '0169': Bic(
    value: 'NACNESMM',
    bankName: 'Banco de la Nación Argentina, Sucursal en España',
    bankShortName: 'Banco de la Nación Argentina, Sucursal en España',
    bankAddress: 'Cl Núñez de Balboa, 73',
    bankPostcode: '28001',
    bankLocation: 'Madrid',
  ),
  '0182': Bic(
    value: 'BBVAESMM',
    bankName: 'Banco Bilbao Vizcaya Argentaria, S.A.',
    bankShortName: 'Banco Bilbao Vizcaya Argentaria, S.A.',
    bankAddress: 'Pz de San Nicolás, 4',
    bankPostcode: '48005',
    bankLocation: 'Bilbao',
  ),
  '0184': Bic(
    value: 'BEDFESM1',
    bankName: 'Banco Europeo de Finanzas, S.A.',
    bankShortName: 'Banco Europeo de Finanzas, S.A.',
    bankAddress: 'Cl Bolsa, 4',
    bankPostcode: '29015',
    bankLocation: 'Málaga',
  ),
  '0186': Bic(
    value: 'BFIVESBB',
    bankName: 'Banco Mediolanum, S.A.',
    bankShortName: 'Banco Mediolanum, S.A.',
    bankAddress: 'CL BARCAS, 10',
    bankPostcode: '46002',
    bankLocation: 'VALENCIA',
  ),
  '0188': Bic(
    value: 'ALCLESMM',
    bankName: 'Banco Alcalá, S.A.',
    bankShortName: 'Banco Alcalá, S.A.',
    bankAddress: 'Cl José Ortega y Gasset, 7',
    bankPostcode: '28006',
    bankLocation: 'Madrid',
  ),
  '0198': Bic(
    value: 'BCOEESMM',
    bankName: 'Banco Cooperativo Español, S.A.',
    bankShortName: 'Banco Cooperativo Español, S.A.',
    bankAddress: 'Cl Virgen de los Peligros, 4',
    bankPostcode: '28013',
    bankLocation: 'Madrid',
  ),
  '0200': Bic(
    value: 'DEGRESBBXXX',
    bankName: 'ANDBANK ESPAÑA BANCA PRIVADA, S.A.',
    bankShortName: 'ANDBANK ESPAÑA BANCA PRIVADA, S.A.',
    bankAddress: 'PS DE LA CASTELLANA, 55',
    bankPostcode: '28046',
    bankLocation: 'MADRID',
  ),
  '0211': Bic(
    value: 'PROAESMM',
    bankName: 'EBN Banco de Negocios, S.A.',
    bankShortName: 'EBN Banco de Negocios, S.A.',
    bankAddress: 'Ps de Recoletos, 29',
    bankPostcode: '28004',
    bankLocation: 'Madrid',
  ),
  '0216': Bic(
    value: 'CMCIESMM',
    bankName: 'Targobank, S.A.',
    bankShortName: 'Targobank, S.A.',
    bankAddress: 'CL CANTÓN CLAUDINO PITA, 2',
    bankPostcode: '28043',
    bankLocation: 'MADRID',
  ),
  '0218': Bic(
    value: 'FCEFESM1',
    bankName: 'FCE Bank Plc Sucursal en España',
    bankShortName: 'FCE Bank Plc Sucursal en España',
    bankAddress: 'CL CALÉNDULA, 13',
    bankPostcode: '28109',
    bankLocation: 'ALCOBENDAS',
  ),
  '0219': Bic(
    value: 'BMCEESMM',
    bankName: 'Bank of Africa Europe, S.A.',
    bankShortName: 'Bank of Africa Europe, S.A.',
    bankAddress: 'Cl Serrano, 59',
    bankPostcode: '28006',
    bankLocation: 'Madrid',
  ),
  '0220': Bic(
    value: 'FIOFESM1',
    bankName: 'BANCO FINANTIA, S.A., SUCURSAL EN ESPAÑA',
    bankShortName: 'BANCO FINANTIA, S.A., SUCURSAL EN ESPAÑA',
    bankAddress: 'AV MENÉNDEZ PELAYO, 67',
    bankPostcode: '28009',
    bankLocation: 'MADRID',
  ),
  '0224': Bic(
    value: 'SCFBESMM',
    bankName: 'Santander Consumer Finance, S.A.',
    bankShortName: 'Santander Consumer Finance, S.A.',
    bankAddress: 'Av de Cantabria, sn',
    bankPostcode: '28660',
    bankLocation: 'Boadilla del Monte',
  ),
  '0225': Bic(
    value: 'FIEIESM1',
    bankName: 'Banco Cetelem, S.A.',
    bankShortName: 'Banco Cetelem, S.A.',
    bankAddress: 'PASEO DE LOS MELANCÓLICOS, 14',
    bankPostcode: '28005',
    bankLocation: 'Madrid',
  ),
  '0226': Bic(
    value: 'UBSWESMMNPB',
    bankName: 'UBS Europe SE, Sucursal en España',
    bankShortName: 'UBS Europe SE, Sucursal en España',
    bankAddress: 'CL MARÍA DE MOLINA, 4',
    bankPostcode: '28006',
    bankLocation: 'MADRID',
  ),
  '0229': Bic(
    value: 'POPLESMM',
    bankName: 'Wizink Bank, S.A.',
    bankShortName: 'Wizink Bank, S.A.',
    bankAddress: 'Cl Ulises, 16-18',
    bankPostcode: '28043',
    bankLocation: 'Madrid',
  ),
  '0232': Bic(
    value: 'INVLESMM',
    bankName: 'Banco Inversis, S.A.',
    bankShortName: 'Banco Inversis, S.A.',
    bankAddress: 'Av de la Hispanidad, 6',
    bankPostcode: '28042',
    bankLocation: 'Madrid',
  ),
  '0234': Bic(
    value: 'CCOCESMM',
    bankName: 'CBNK BANCO DE COLECTIVOS, S.A.',
    bankShortName: 'CBNK BANCO DE COLECTIVOS, S.A.',
    bankAddress: 'CL ALMAGRO, 8',
    bankPostcode: '28010',
    bankLocation: 'MADRID',
  ),
  '0237': Bic(
    value: 'CSURES2C',
    bankName: 'Cajasur Banco, S.A.',
    bankShortName: 'Cajasur Banco, S.A.',
    bankAddress: 'AV. GRAN CAPITÁN, 11-13',
    bankPostcode: '14008',
    bankLocation: 'CÓRDOBA',
  ),
  '0235': Bic(
    value: 'PICHESMM',
    bankName: 'Banco Pichincha España, S.A..',
    bankShortName: 'Banco Pichincha España, S.A..',
    bankAddress: 'Cl Lagasca, 4',
    bankPostcode: '28001',
    bankLocation: 'Madrid',
  ),
  'W0075543I': Bic(
    value: 'MSTAESM1XXX',
    bankName: 'MORGAN STANLEY EUROPE SE, SUCURSAL EN ESPAÑA',
    bankShortName: 'MORGAN STANLEY EUROPE SE, SUCURSAL EN ESPAÑA',
    bankAddress: 'C/ SERRANO 55',
    bankPostcode: '28006',
    bankLocation: 'MADRID',
  ),
  'A79192258': Bic(
    value: 'CRESESM2XXX',
    bankName: 'Credit Suisse Bank (Europe), S.A.',
    bankShortName: 'Credit Suisse Bank (Europe), S.A.',
    bankAddress: 'CL AYALA, 42 - 3º B',
    bankPostcode: '28001',
    bankLocation: 'MADRID',
  ),
  '0239': Bic(
    value: 'EVOBESMMXXX',
    bankName: 'Evo Banco S.A.',
    bankShortName: 'Evo Banco S.A.',
    bankAddress: 'Cl Serrano, 45',
    bankPostcode: '28001',
    bankLocation: 'Madrid',
  ),
  'A06302657': Bic(
    value: 'MRTFESM2XXX',
    bankName: 'MIRALTA FINANCE BANK, S.A.',
    bankShortName: 'MIRALTA FINANCE BANK, S.A.',
    bankAddress: 'PLAZA MANUEL GOMEZ MORENO, 2',
    bankPostcode: '28020',
    bankLocation: 'MADRID',
  ),
  '0240': Bic(
    value: 'BCCAESMMXXX',
    bankName: 'Banco de Crédito Social Cooperativo',
    bankShortName: 'Banco de Crédito Social Cooperativo',
    bankAddress: 'Pº Castellana, 87',
    bankPostcode: '28046',
    bankLocation: 'Madrid',
  ),
  '0241': Bic(
    value: 'AYGBESMMXXX',
    bankName: 'A&G BANCO, S.A.',
    bankShortName: 'A&G BANCO, S.A.',
    bankAddress: 'Paseo de la Castellana, 92',
    bankPostcode: '28046',
    bankLocation: 'Madrid',
  ),
};

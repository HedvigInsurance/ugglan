import Foundation

extension String {
    public var bankName: String? {
        let digits = self.filter(\.isNumber)
        return Int(digits)?.bankNameForClearing
            ?? Int(String(digits.prefix(4)))?.bankNameForClearing
    }
}

extension Int {
    fileprivate var bankNameForClearing: String? {
        switch self {
        case 1000...1099: return "Sveriges Riksbank"
        case 1100...1199: return "Nordea"
        case 1200...1399: return "Danske Bank"
        case 1400...2099: return "Nordea"
        case 2300...2399: return "Ålandsbanken"
        case 2400...2499: return "Danske Bank"
        case 3000...3399: return "Nordea"
        case 3400...3409: return "Länsförsäkringar Bank"
        case 3410...4999: return "Nordea"
        case 5000...5999: return "SEB"
        case 6000...6999: return "Handelsbanken"
        case 7000...8999: return "Swedbank"
        case 9020...9029: return "Länsförsäkringar Bank"
        case 9040...9049: return "Citibank"
        case 9060...9069: return "Länsförsäkringar Bank"
        case 9070...9079: return "Multitude Bank"
        case 9080...9089: return "Crédit Agricole Corporate"
        case 9100...9109: return "Nordnet Bank"
        case 9120...9124: return "SEB"
        case 9130...9149: return "SEB"
        case 9150...9169: return "Skandiabanken"
        case 9170...9179: return "IKANO Banken"
        case 9180...9189: return "Danske Bank"
        case 9190...9199: return "DNB Bank"
        case 9230...9239: return "Marginalen Bank"
        case 9250...9259: return "SBAB Bank"
        case 9260...9269: return "DNB Bank"
        case 9270...9279: return "ICA Banken"
        case 9280...9289: return "Resurs Bank"
        case 9300...9349: return "Swedbank"
        case 9380...9389: return "Pareto Securities"
        case 9390...9399: return "Landshypotek"
        case 9400...9449: return "Forex Bank"
        case 9460...9469: return "Santander Consumer Bank"
        case 9470...9479: return "BNP Paribas"
        case 9490...9499: return "Brite"
        case 9500...9549: return "Nordea"
        case 9550...9569: return "Avanza Bank"
        case 9570...9579: return "Sparbanken Syd"
        case 9580...9589: return "AION Bank"
        case 9590...9599: return "Erik Penser Bank"
        case 9600...9609: return "Banking Circle"
        case 9610...9619: return "Volvofinans Bank"
        case 9620...9629: return "Bank of China"
        case 9630...9639: return "Lån & Spar Bank"
        case 9640...9649: return "Nordax Bank"
        case 9650...9659: return "MedMera Bank"
        case 9660...9669: return "Svea Bank"
        case 9670...9679: return "JAK Medlemsbank"
        case 9680...9689: return "Bluestep Finans"
        case 9690...9699: return "Folkia"
        case 9700...9709: return "Ekobanken"
        case 9710...9719: return "Lunar Bank"
        case 9750...9759: return "Northmill Bank"
        case 9770...9779: return "Intergiro"
        case 9780...9789: return "Klarna Bank"
        case 9860...9869: return "Privatgirot"
        case 9870...9879: return "Nasdaq OMX"
        case 9880...9899: return "Riksgälden"
        case 9951: return "Teller Branch Norway"
        case 9952: return "Bankernas Automatbolag"
        case 9953: return "Teller Branch Sweden"
        case 9954: return "Kortaccept Nordic"
        case 9955: return "Kommuninvest"
        case 9956: return "VP Securities"
        case 9960...9969: return "Nordea"
        default: return nil
        }
    }
}

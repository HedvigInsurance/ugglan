struct AddonLogInfo: Codable {
    let flow: AddonSource
    let subType: String
    let type: AddonType

    enum AddonType: String, Codable {
        case travelAddon
    }

    var asAddonAttributes: [String: AddonLogInfo] {
        return ["addon": self]
    }
}

enum AddonEventType: String, Codable {
    case addonPurchased
    case addonUpgraded
}

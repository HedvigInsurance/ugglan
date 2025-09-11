struct AddonLogInfo: Codable {
    let flow: AddonSource
    let subType: String
    let type: AddonType

    enum AddonType: String, Codable {
        case travelAddon = "TRAVEL_ADDON"
    }

    var asAddonAttributes: [String: AddonLogInfo] {
        ["addon": self]
    }
}

enum AddonEventType: String, Codable {
    case addonPurchased = "ADDON_PURCHASED"
    case addonUpgraded = "ADDON_UPGRADED"
}

struct AddonLogInfo: Codable {
    let flow: AddonSource
    let type: String
    let subType: String?

    var asAddonAttributes: [String: AddonLogInfo] {
        ["addon": self]
    }
}

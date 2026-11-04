import Foundation

public struct ChangeAddonInput: Identifiable, Equatable, Sendable {
    public let id: String = UUID().uuidString

    public let contractInfos: [AddonContractInfo]?
    public let addonSource: AddonSource
    public let preselectedAddonTitle: String?
    public init(
        addonSource: AddonSource,
        contractInfos: [AddonContractInfo]? = nil,
        preselectedAddonTitle: String? = nil
    ) {
        self.addonSource = addonSource
        self.contractInfos = contractInfos
        self.preselectedAddonTitle = preselectedAddonTitle
    }
}

public enum AddonSource: String, Codable, Sendable {
    case insurances = "INSURANCES_TAB"
    case contractDetail = "CONTRACT_DETAIL"
    case homeScreen = "HOME_SCREEN"
    case homeCrossSellSheet = "HOME_CROSS_SELL_SHEET"
    case travelCertificates = "TRAVEL_CERTIFICATES"
    case deeplink = "DEEPLINK"
}

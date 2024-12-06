import hCoreUI

public struct TerminationConfirmConfig: Codable & Equatable & Hashable & Sendable {
    public var contractId: String
    public var contractDisplayName: String
    public var contractExposureName: String
    public var activeFrom: String?
    public var typeOfContract: TypeOfContract?
    public var addonDisplayItems: [AddonDisplayItem]?

    public init(
        contractId: String,
        contractDisplayName: String,
        contractExposureName: String,
        activeFrom: String?,
        typeOfContract: TypeOfContract?,
        addonDisplayItems: [AddonDisplayItem]? = nil
    ) {
        self.contractId = contractId
        self.contractDisplayName = contractDisplayName
        self.contractExposureName = contractExposureName
        self.activeFrom = activeFrom
        self.typeOfContract = typeOfContract
        self.addonDisplayItems = addonDisplayItems
    }
}

public struct AddonDisplayItem: Codable, Equatable, Hashable, Sendable {
    let title: String
    let value: String
}
